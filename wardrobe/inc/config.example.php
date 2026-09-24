<?php
// Salin file ini menjadi `config.local.php` (di folder yang sama) lalu isi
// sesuai server Anda. `config.local.php` tidak ikut masuk git.
//
// Setiap nilai juga bisa di-override lewat environment variable:
// WARDROBE_DB_HOST, WARDROBE_DB_USER, WARDROBE_DB_PASS, WARDROBE_DB_NAME.
//
// Sebaiknya jangan pakai user `root`; buat user khusus, contoh:
//   CREATE USER 'wardrobe'@'localhost' IDENTIFIED BY 'password-yang-kuat';
//   GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON wardrobe.* TO 'wardrobe'@'localhost';

return [
    'db_host' => 'localhost',
    'db_user' => 'wardrobe',
    'db_pass' => 'ganti-dengan-password-anda',
    'db_name' => 'wardrobe',
];
