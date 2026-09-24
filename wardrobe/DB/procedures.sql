-- Wardrobe: stored procedures.
-- Aman di-import berulang kali (setiap procedure di-DROP dulu).
-- Nama tabel sengaja huruf kecil agar jalan di MySQL/MariaDB Linux
-- (lower_case_table_names = 0).

DELIMITER $$

DROP PROCEDURE IF EXISTS `DisplayAllData`$$
CREATE PROCEDURE `DisplayAllData` ()
BEGIN
    SELECT 'baju' AS jenis, BAJU_ID AS id, BAJU_NAMA AS nama, BAJU_DESKRIPSI AS deskripsi, BAJU_FOTO AS foto
    FROM baju
    UNION ALL
    SELECT 'celana', CELANA_ID, CEL_NAMA, CEL_DESKRIPSI, CEL_FOTO
    FROM celana
    UNION ALL
    SELECT 'aksesoris', AKSESORIS_ID, ACC_NAMA, ACC_DESKRIPSI, ACC_FOTO
    FROM aksesoris
    ORDER BY jenis, nama;
END$$

-- 2 baju + 1 celana + 1 aksesoris acak, tidak termasuk yang sedang di laundry.
DROP PROCEDURE IF EXISTS `Dress_Me`$$
CREATE PROCEDURE `Dress_Me` ()
BEGIN
    (SELECT 'baju' AS jenis, b.BAJU_ID AS id, b.BAJU_NAMA AS nama, b.BAJU_DESKRIPSI AS deskripsi, b.BAJU_FOTO AS foto
     FROM baju b
     WHERE NOT EXISTS (SELECT 1 FROM laundry l WHERE l.LAUNDRY_BAJU_ID = b.BAJU_ID)
     ORDER BY RAND() LIMIT 2)
    UNION ALL
    (SELECT 'celana', c.CELANA_ID, c.CEL_NAMA, c.CEL_DESKRIPSI, c.CEL_FOTO
     FROM celana c
     WHERE NOT EXISTS (SELECT 1 FROM laundry l WHERE l.LAUNDRY_CEL_ID = c.CELANA_ID)
     ORDER BY RAND() LIMIT 1)
    UNION ALL
    (SELECT 'aksesoris', a.AKSESORIS_ID, a.ACC_NAMA, a.ACC_DESKRIPSI, a.ACC_FOTO
     FROM aksesoris a
     WHERE NOT EXISTS (SELECT 1 FROM laundry l WHERE l.LAUNDRY_ACC_ID = a.AKSESORIS_ID)
     ORDER BY RAND() LIMIT 1);
END$$

DROP PROCEDURE IF EXISTS `GetAllLaundryData`$$
CREATE PROCEDURE `GetAllLaundryData` ()
BEGIN
    SELECT l.LAUNDRY_ID, 'baju' AS jenis, b.BAJU_ID AS id, b.BAJU_NAMA AS nama, b.BAJU_DESKRIPSI AS deskripsi, b.BAJU_FOTO AS foto
    FROM laundry l JOIN baju b ON l.LAUNDRY_BAJU_ID = b.BAJU_ID
    UNION ALL
    SELECT l.LAUNDRY_ID, 'celana', c.CELANA_ID, c.CEL_NAMA, c.CEL_DESKRIPSI, c.CEL_FOTO
    FROM laundry l JOIN celana c ON l.LAUNDRY_CEL_ID = c.CELANA_ID
    UNION ALL
    SELECT l.LAUNDRY_ID, 'aksesoris', a.AKSESORIS_ID, a.ACC_NAMA, a.ACC_DESKRIPSI, a.ACC_FOTO
    FROM laundry l JOIN aksesoris a ON l.LAUNDRY_ACC_ID = a.AKSESORIS_ID
    ORDER BY jenis, nama;
END$$

DROP PROCEDURE IF EXISTS `InsertBaju`$$
CREATE PROCEDURE `InsertBaju` (IN `nama_param` VARCHAR(255), IN `deskripsi_param` TEXT, IN `foto_param` VARCHAR(255))
BEGIN
    INSERT INTO baju (BAJU_NAMA, BAJU_DESKRIPSI, BAJU_FOTO)
    VALUES (nama_param, deskripsi_param, foto_param);
END$$

DROP PROCEDURE IF EXISTS `InsertCelana`$$
CREATE PROCEDURE `InsertCelana` (IN `nama_param` VARCHAR(255), IN `deskripsi_param` TEXT, IN `foto_param` VARCHAR(255))
BEGIN
    INSERT INTO celana (CEL_NAMA, CEL_DESKRIPSI, CEL_FOTO)
    VALUES (nama_param, deskripsi_param, foto_param);
END$$

DROP PROCEDURE IF EXISTS `InsertAksesoris`$$
CREATE PROCEDURE `InsertAksesoris` (IN `nama_param` VARCHAR(255), IN `deskripsi_param` TEXT, IN `foto_param` VARCHAR(255))
BEGIN
    INSERT INTO aksesoris (ACC_NAMA, ACC_DESKRIPSI, ACC_FOTO)
    VALUES (nama_param, deskripsi_param, foto_param);
END$$

DROP PROCEDURE IF EXISTS `EditBaju`$$
CREATE PROCEDURE `EditBaju` (IN `baju_id_param` INT, IN `new_nama_param` VARCHAR(255), IN `new_deskripsi_param` TEXT, IN `new_foto_param` VARCHAR(255))
BEGIN
    UPDATE baju
    SET BAJU_NAMA = new_nama_param, BAJU_DESKRIPSI = new_deskripsi_param, BAJU_FOTO = new_foto_param
    WHERE BAJU_ID = baju_id_param;
END$$

DROP PROCEDURE IF EXISTS `EditCelana`$$
CREATE PROCEDURE `EditCelana` (IN `celana_id_param` INT, IN `new_nama_param` VARCHAR(255), IN `new_deskripsi_param` TEXT, IN `new_foto_param` VARCHAR(255))
BEGIN
    UPDATE celana
    SET CEL_NAMA = new_nama_param, CEL_DESKRIPSI = new_deskripsi_param, CEL_FOTO = new_foto_param
    WHERE CELANA_ID = celana_id_param;
END$$

DROP PROCEDURE IF EXISTS `EditAksesoris`$$
CREATE PROCEDURE `EditAksesoris` (IN `aksesoris_id_param` INT, IN `new_nama_param` VARCHAR(255), IN `new_deskripsi_param` TEXT, IN `new_foto_param` VARCHAR(255))
BEGIN
    UPDATE aksesoris
    SET ACC_NAMA = new_nama_param, ACC_DESKRIPSI = new_deskripsi_param, ACC_FOTO = new_foto_param
    WHERE AKSESORIS_ID = aksesoris_id_param;
END$$

DROP PROCEDURE IF EXISTS `DeleteFromBaju`$$
CREATE PROCEDURE `DeleteFromBaju` (IN `baju_id_param` INT)
BEGIN
    DELETE FROM baju WHERE BAJU_ID = baju_id_param;
END$$

DROP PROCEDURE IF EXISTS `DeleteFromCelana`$$
CREATE PROCEDURE `DeleteFromCelana` (IN `celana_id_param` INT)
BEGIN
    DELETE FROM celana WHERE CELANA_ID = celana_id_param;
END$$

DROP PROCEDURE IF EXISTS `DeleteFromAksesoris`$$
CREATE PROCEDURE `DeleteFromAksesoris` (IN `aksesoris_id_param` INT)
BEGIN
    DELETE FROM aksesoris WHERE AKSESORIS_ID = aksesoris_id_param;
END$$

DROP PROCEDURE IF EXISTS `InsertIntoLaundry`$$
CREATE PROCEDURE `InsertIntoLaundry` (IN `baju_id_param` INT, IN `celana_id_param` INT, IN `aksesoris_id_param` INT)
BEGIN
    IF (baju_id_param IS NOT NULL) + (celana_id_param IS NOT NULL) + (aksesoris_id_param IS NOT NULL) <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Isi tepat satu pakaian per baris laundry';
    END IF;

    INSERT INTO laundry (LAUNDRY_BAJU_ID, LAUNDRY_CEL_ID, LAUNDRY_ACC_ID)
    VALUES (baju_id_param, celana_id_param, aksesoris_id_param);
END$$

DROP PROCEDURE IF EXISTS `DeleteFromLaundry`$$
CREATE PROCEDURE `DeleteFromLaundry` (IN `laundry_id_param` INT)
BEGIN
    DELETE FROM laundry WHERE LAUNDRY_ID = laundry_id_param;
END$$

DELIMITER ;
