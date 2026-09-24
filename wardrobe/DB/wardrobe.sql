-- Wardrobe: schema untuk instalasi baru.
--
-- Cara pakai:
--   1. Buat database kosong bernama `wardrobe`.
--   2. Import file ini, lalu import `procedures.sql`.
--
-- Sudah punya database versi lama? Jangan import file ini;
-- jalankan `migrate_v2.sql` lalu `procedures.sql`.

SET NAMES utf8mb4;

CREATE TABLE `baju` (
  `BAJU_ID` int(11) NOT NULL AUTO_INCREMENT,
  `BAJU_NAMA` varchar(255) NOT NULL,
  `BAJU_DESKRIPSI` text NOT NULL,
  `BAJU_FOTO` varchar(255) NOT NULL,
  PRIMARY KEY (`BAJU_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `celana` (
  `CELANA_ID` int(11) NOT NULL AUTO_INCREMENT,
  `CEL_NAMA` varchar(255) NOT NULL,
  `CEL_DESKRIPSI` text NOT NULL,
  `CEL_FOTO` varchar(255) NOT NULL,
  PRIMARY KEY (`CELANA_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `aksesoris` (
  `AKSESORIS_ID` int(11) NOT NULL AUTO_INCREMENT,
  `ACC_NAMA` varchar(255) NOT NULL,
  `ACC_DESKRIPSI` text NOT NULL,
  `ACC_FOTO` varchar(255) NOT NULL,
  PRIMARY KEY (`AKSESORIS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Satu baris = satu pakaian yang sedang di laundry; tepat satu kolom *_ID yang
-- terisi (dicek oleh procedure InsertIntoLaundry). UNIQUE mencegah pakaian yang
-- sama masuk dua kali, dan ON DELETE CASCADE membersihkan laundry saat pakaian dijual.
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

-- Pengaturan aplikasi (saat ini: hash password login).
CREATE TABLE `app_settings` (
  `setting_key` varchar(64) NOT NULL,
  `setting_value` text NOT NULL,
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
