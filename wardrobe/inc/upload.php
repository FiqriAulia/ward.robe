<?php
// Upload & hapus foto pakaian di folder gambar/.

/** Error upload yang pesannya aman ditampilkan ke user. */
class UploadError extends RuntimeException
{
}

const MAX_UPLOAD_BYTES = 5 * 1024 * 1024;

const ALLOWED_IMAGE_TYPES = [
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/gif' => 'gif',
    'image/webp' => 'webp',
];

/**
 * Validasi & simpan foto upload. Nama file dibuat acak dan ekstensinya
 * ditentukan dari isi file (bukan dari nama aslinya), sehingga file seperti
 * `shell.php` tidak mungkin tersimpan sebagai script.
 *
 * @return string nama file di folder gambar/
 */
function store_uploaded_image(array $file): string
{
    $error = $file['error'] ?? UPLOAD_ERR_NO_FILE;
    if (is_array($error)) {
        throw new UploadError('Upload satu foto saja.');
    }
    switch ($error) {
        case UPLOAD_ERR_OK:
            break;
        case UPLOAD_ERR_NO_FILE:
            throw new UploadError('Foto wajib diisi.');
        case UPLOAD_ERR_INI_SIZE:
        case UPLOAD_ERR_FORM_SIZE:
            throw new UploadError('Foto terlalu besar (maksimal 5 MB).');
        default:
            throw new UploadError('Upload foto gagal, coba lagi.');
    }

    $tmp = $file['tmp_name'] ?? '';
    if (!is_uploaded_file($tmp)) {
        throw new UploadError('Upload foto gagal, coba lagi.');
    }
    if (filesize($tmp) > MAX_UPLOAD_BYTES) {
        throw new UploadError('Foto terlalu besar (maksimal 5 MB).');
    }

    $mime = (new finfo(FILEINFO_MIME_TYPE))->file($tmp);
    if (!isset(ALLOWED_IMAGE_TYPES[$mime]) || @getimagesize($tmp) === false) {
        throw new UploadError('File harus berupa gambar JPG, PNG, GIF, atau WEBP.');
    }

    if (!is_dir(UPLOAD_DIR) && !mkdir(UPLOAD_DIR, 0755, true)) {
        throw new RuntimeException('Tidak bisa membuat folder ' . UPLOAD_DIR);
    }

    $name = bin2hex(random_bytes(16)) . '.' . ALLOWED_IMAGE_TYPES[$mime];
    if (!move_uploaded_file($tmp, UPLOAD_DIR . '/' . $name)) {
        throw new RuntimeException('move_uploaded_file gagal untuk ' . $name);
    }
    return $name;
}

/** Path foto di disk, atau null bila nama file tidak valid / file tidak ada. */
function image_path(?string $name): ?string
{
    // Foto dari versi lama memakai nama asli dari user, jadi cukup pastikan
    // nama itu tidak keluar dari folder gambar/.
    if ($name === null || $name === '' || $name[0] === '.' || strpbrk($name, "/\\\0") !== false) {
        return null;
    }
    $path = UPLOAD_DIR . '/' . $name;
    return is_file($path) ? $path : null;
}

function delete_image(?string $name): void
{
    $path = image_path($name);
    if ($path !== null) {
        unlink($path);
    }
}

function image_url(string $name): string
{
    return url('gambar/' . $name);
}
