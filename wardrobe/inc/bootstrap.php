<?php
// Di-include paling awal oleh setiap halaman.
//
// Halaman yang boleh dibuka tanpa login mendefinisikan PUBLIC_PAGE sebelum
// meng-include file ini; selain itu login wajib.

declare(strict_types=1);

define('APP_ROOT', dirname(__DIR__));
define('UPLOAD_DIR', APP_ROOT . '/gambar');

// Prefix relatif ke root aplikasi: '' untuk halaman di root, '../' untuk
// halaman di subfolder (main/, v_input/, dst). Semua link lewat url().
define('BASE', realpath(dirname($_SERVER['SCRIPT_FILENAME'])) === realpath(APP_ROOT) ? '' : '../');

require_once __DIR__ . '/helpers.php';
require_once APP_ROOT . '/koneksi.php';
require_once __DIR__ . '/upload.php';
require_once __DIR__ . '/layout.php';
require_once APP_ROOT . '/c_wardrobe.php';

set_exception_handler('handle_uncaught');
send_security_headers();
start_session();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_verify();
}

if (!defined('PUBLIC_PAGE')) {
    require_login();
}
