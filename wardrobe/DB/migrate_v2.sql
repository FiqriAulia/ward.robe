-- Wardrobe: migrasi database versi lama (1.x) ke versi 2.
--
-- BACKUP DULU database Anda (Export di phpMyAdmin) sebelum menjalankan ini.
-- Setelah selesai, import `procedures.sql`.
--
-- Yang dilakukan:
--   * ID pakaian dinomori ulang 1, 2, 3, ... dan dijadikan AUTO_INCREMENT
--     (ID lama berasal dari angka acak dan ada yang mentok di 2147483647).
--   * Kolom nama/deskripsi/foto dijadikan NOT NULL.
--   * Tabel laundry dibuat ulang: satu baris per pakaian, mendukung aksesoris,
--     tidak bisa dobel, dan ikut terhapus saat pakaian dijual.
--   * Tabel app_settings (password login) ditambahkan.

SET NAMES utf8mb4;

-- 1. Simpan isi laundry lama, lalu buang tabelnya (beserta foreign key lamanya).
CREATE TEMPORARY TABLE old_laundry AS
    SELECT LAUNDRY_BAJU_ID AS baju_id, LAUNDRY_CEL_ID AS celana_id FROM laundry;
DROP TABLE laundry;

-- 2. Nomori ulang ID. Lewat angka negatif dulu supaya tidak bentrok dengan ID yang masih ada.
SET @n := 0;
CREATE TEMPORARY TABLE map_baju AS SELECT BAJU_ID AS old_id, (@n := @n + 1) AS new_id FROM baju;
UPDATE baju b JOIN map_baju m ON b.BAJU_ID = m.old_id SET b.BAJU_ID = -m.new_id;
UPDATE baju SET BAJU_ID = -BAJU_ID;

SET @n := 0;
CREATE TEMPORARY TABLE map_celana AS SELECT CELANA_ID AS old_id, (@n := @n + 1) AS new_id FROM celana;
UPDATE celana c JOIN map_celana m ON c.CELANA_ID = m.old_id SET c.CELANA_ID = -m.new_id;
UPDATE celana SET CELANA_ID = -CELANA_ID;

SET @n := 0;
CREATE TEMPORARY TABLE map_aksesoris AS SELECT AKSESORIS_ID AS old_id, (@n := @n + 1) AS new_id FROM aksesoris;
UPDATE aksesoris a JOIN map_aksesoris m ON a.AKSESORIS_ID = m.old_id SET a.AKSESORIS_ID = -m.new_id;
UPDATE aksesoris SET AKSESORIS_ID = -AKSESORIS_ID;

-- 3. AUTO_INCREMENT dan NOT NULL.
UPDATE baju SET BAJU_NAMA = COALESCE(BAJU_NAMA, ''), BAJU_DESKRIPSI = COALESCE(BAJU_DESKRIPSI, ''), BAJU_FOTO = COALESCE(BAJU_FOTO, '');
ALTER TABLE baju
    MODIFY BAJU_ID int(11) NOT NULL AUTO_INCREMENT,
    MODIFY BAJU_NAMA varchar(255) NOT NULL,
    MODIFY BAJU_DESKRIPSI text NOT NULL,
    MODIFY BAJU_FOTO varchar(255) NOT NULL;

UPDATE celana SET CEL_NAMA = COALESCE(CEL_NAMA, ''), CEL_DESKRIPSI = COALESCE(CEL_DESKRIPSI, ''), CEL_FOTO = COALESCE(CEL_FOTO, '');
ALTER TABLE celana
    MODIFY CELANA_ID int(11) NOT NULL AUTO_INCREMENT,
    MODIFY CEL_NAMA varchar(255) NOT NULL,
    MODIFY CEL_DESKRIPSI text NOT NULL,
    MODIFY CEL_FOTO varchar(255) NOT NULL;

UPDATE aksesoris SET ACC_NAMA = COALESCE(ACC_NAMA, ''), ACC_DESKRIPSI = COALESCE(ACC_DESKRIPSI, ''), ACC_FOTO = COALESCE(ACC_FOTO, '');
ALTER TABLE aksesoris
    MODIFY AKSESORIS_ID int(11) NOT NULL AUTO_INCREMENT,
    MODIFY ACC_NAMA varchar(255) NOT NULL,
    MODIFY ACC_DESKRIPSI text NOT NULL,
    MODIFY ACC_FOTO varchar(255) NOT NULL;

-- 4. Tabel laundry baru, diisi dari data lama (pasangan baju+celana dipecah jadi dua baris).
CREATE TABLE `laundry` (
  `LAUNDRY_ID` int(11) NOT NULL AUTO_INCREMENT,
  `LAUNDRY_BAJU_ID` int(11) DEFAULT NULL,
  `LAUNDRY_CEL_ID` int(11) DEFAULT NULL,
  `LAUNDRY_ACC_ID` int(11) DEFAULT NULL,
  PRIMARY KEY (`LAUNDRY_ID`),
  UNIQUE KEY `LAUNDRY_BAJU_ID` (`LAUNDRY_BAJU_ID`),
  UNIQUE KEY `LAUNDRY_CEL_ID` (`LAUNDRY_CEL_ID`),
  UNIQUE KEY `LAUNDRY_ACC_ID` (`LAUNDRY_ACC_ID`),
  CONSTRAINT `laundry_baju_fk` FOREIGN KEY (`LAUNDRY_BAJU_ID`) REFERENCES `baju` (`BAJU_ID`) ON DELETE CASCADE,
  CONSTRAINT `laundry_celana_fk` FOREIGN KEY (`LAUNDRY_CEL_ID`) REFERENCES `celana` (`CELANA_ID`) ON DELETE CASCADE,
  CONSTRAINT `laundry_aksesoris_fk` FOREIGN KEY (`LAUNDRY_ACC_ID`) REFERENCES `aksesoris` (`AKSESORIS_ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO laundry (LAUNDRY_BAJU_ID)
    SELECT DISTINCT m.new_id FROM old_laundry o JOIN map_baju m ON m.old_id = o.baju_id;
INSERT INTO laundry (LAUNDRY_CEL_ID)
    SELECT DISTINCT m.new_id FROM old_laundry o JOIN map_celana m ON m.old_id = o.celana_id;

-- 5. Pengaturan aplikasi.
CREATE TABLE IF NOT EXISTS `app_settings` (
  `setting_key` varchar(64) NOT NULL,
  `setting_value` text NOT NULL,
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TEMPORARY TABLE old_laundry, map_baju, map_celana, map_aksesoris;
