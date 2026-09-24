<?php
// Koneksi database. Kredensial dibaca dari inc/config.local.php
// (lihat inc/config.example.php) atau environment variable WARDROBE_DB_*.

/** Dilempar saat konfigurasi/database belum siap; ditampilkan sebagai halaman instalasi. */
class InstallRequired extends RuntimeException
{
}

function db_config(): array
{
    $file = APP_ROOT . '/inc/config.local.php';
    $config = is_file($file) ? require $file : null;
    if (!is_array($config)) {
        $config = [];
    }

    foreach (['db_host', 'db_user', 'db_pass', 'db_name'] as $key) {
        $env = getenv('WARDROBE_' . strtoupper($key));
        if ($env !== false) {
            $config[$key] = $env;
        }
    }

    if (!isset($config['db_host'], $config['db_user'], $config['db_pass'], $config['db_name'])) {
        throw new InstallRequired('inc/config.local.php belum dibuat');
    }
    return $config;
}

/** Satu koneksi bersama untuk seluruh request. */
function db(): mysqli
{
    static $db = null;
    if ($db !== null) {
        return $db;
    }

    // Semua error MySQL jadi exception, jadi kegagalan tidak pernah diam-diam diabaikan.
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

    $config = db_config();
    try {
        $db = new mysqli($config['db_host'], $config['db_user'], $config['db_pass'], $config['db_name']);
    } catch (mysqli_sql_exception $e) {
        throw new InstallRequired($e->getMessage(), 0, $e);
    }
    $db->set_charset('utf8mb4');
    return $db;
}

/**
 * Jalankan query / CALL dengan prepared statement dan kembalikan semua baris
 * (array kosong bila tidak ada result set).
 */
function db_rows(string $sql, string $types = '', array $params = []): array
{
    $stmt = db()->prepare($sql);
    if ($params) {
        $stmt->bind_param($types, ...$params);
    }
    $stmt->execute();

    $result = $stmt->get_result();
    $rows = $result ? $result->fetch_all(MYSQLI_ASSOC) : [];

    // CALL selalu menghasilkan result set tambahan; habiskan supaya query
    // berikutnya tidak kena "Commands out of sync".
    while ($stmt->more_results()) {
        $stmt->next_result();
    }
    $stmt->close();

    return $rows;
}
