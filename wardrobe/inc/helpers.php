<?php

/** Escape untuk output HTML (teks maupun atribut). */
function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/**
 * URL relatif ke root aplikasi, aman dari spasi/kurung siku di nama file.
 * Contoh: url('main/v_laundri[ed].php') -> '../main/v_laundri%5Bed%5D.php'
 */
function url(string $path, array $query = []): string
{
    $encoded = implode('/', array_map('rawurlencode', explode('/', $path)));
    return BASE . $encoded . ($query ? '?' . http_build_query($query) : '');
}

function redirect(string $path, array $query = []): void
{
    header('Location: ' . url($path, $query));
    exit;
}

function is_https(): bool
{
    return (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || ($_SERVER['SERVER_PORT'] ?? null) == 443;
}

function send_security_headers(): void
{
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: same-origin');
    header("Content-Security-Policy: default-src 'self'; img-src 'self'; style-src 'self' 'unsafe-inline'; "
        . "script-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'");
}

function start_session(): void
{
    session_name('wardrobe_session');
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/',
        'secure' => is_https(),
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}

// ---- Login -----------------------------------------------------------------

function is_logged_in(): bool
{
    return !empty($_SESSION['logged_in']);
}

function require_login(): void
{
    if (!is_logged_in()) {
        redirect('login.php');
    }
}

function log_in(): void
{
    session_regenerate_id(true);
    $_SESSION['logged_in'] = true;
}

// ---- CSRF ------------------------------------------------------------------

function csrf_token(): string
{
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function csrf_field(): string
{
    return '<input type="hidden" name="csrf_token" value="' . e(csrf_token()) . '">';
}

function csrf_verify(): void
{
    // Request melebihi post_max_size: PHP mengosongkan $_POST (termasuk token).
    if (!$_POST && (int) ($_SERVER['CONTENT_LENGTH'] ?? 0) > 0) {
        http_response_code(413);
        render_message_page('File Terlalu Besar', 'Ukuran upload melebihi batas server. Pakai foto yang lebih kecil.');
        exit;
    }

    $sent = $_POST['csrf_token'] ?? '';
    if (!is_string($sent) || !hash_equals(csrf_token(), $sent)) {
        http_response_code(400);
        render_message_page('Sesi Kedaluwarsa', 'Form sudah kedaluwarsa. Kembali, muat ulang halaman, lalu coba lagi.');
        exit;
    }
}

// ---- Flash message ---------------------------------------------------------

function flash(string $message, string $type = 'info'): void
{
    $_SESSION['flash'][] = ['message' => $message, 'type' => $type];
}

function take_flashes(): array
{
    $flashes = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    return $flashes;
}

/** Simpan error validasi + isian form supaya form bisa ditampilkan ulang setelah redirect. */
function remember_form(array $errors, array $old): void
{
    $_SESSION['form'] = ['errors' => $errors, 'old' => $old];
}

/** @return array{errors: array, old: array} */
function take_form(): array
{
    $form = $_SESSION['form'] ?? ['errors' => [], 'old' => []];
    unset($_SESSION['form']);
    return $form;
}

// ---- Input -----------------------------------------------------------------

/** Ambil teks dari $_POST, sudah di-trim. Selain string dianggap kosong. */
function post_text(string $key): string
{
    $value = $_POST[$key] ?? '';
    return is_string($value) ? trim($value) : '';
}

/** Ambil array string dari $_POST (mis. checkbox name="x[]"). */
function post_list(string $key): array
{
    $value = $_POST[$key] ?? [];
    return is_array($value) ? array_values(array_filter($value, 'is_string')) : [];
}

/** Integer positif dari string, atau null. */
function to_id(mixed $value): ?int
{
    $id = filter_var($value, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
    return $id === false ? null : $id;
}

/** Validasi nama & deskripsi pakaian. Mengembalikan daftar pesan error. */
function validate_item(string $nama, string $deskripsi): array
{
    $errors = [];
    if ($nama === '') {
        $errors[] = 'Nama wajib diisi.';
    } elseif (mb_strlen($nama) > 255) {
        $errors[] = 'Nama maksimal 255 karakter.';
    }
    if ($deskripsi === '') {
        $errors[] = 'Deskripsi wajib diisi.';
    } elseif (mb_strlen($deskripsi) > 5000) {
        $errors[] = 'Deskripsi maksimal 5000 karakter.';
    }
    return $errors;
}

// ---- Error -----------------------------------------------------------------

function not_found(): void
{
    require APP_ROOT . '/handle_not_found.php';
    exit;
}

function handle_uncaught(Throwable $e): void
{
    if ($e instanceof InstallRequired) {
        error_log('Wardrobe: database belum siap: ' . $e->getMessage());
        http_response_code(503);
        render_install_page();
        return;
    }

    error_log('Wardrobe: ' . $e);
    if (!headers_sent()) {
        http_response_code(500);
    }
    render_message_page('Terjadi Kesalahan', 'Maaf, ada yang salah di server. Coba lagi sebentar lagi.');
}
