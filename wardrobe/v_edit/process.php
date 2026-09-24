<?php
require __DIR__ . '/../inc/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect('main/v_edit.php');
}

$controller = new c_wardrobe();
$type = $controller->requireType($_POST['type'] ?? null);
$item = $controller->requireItem($type, $_POST['id'] ?? null);
$nama = post_text('nama');
$deskripsi = post_text('deskripsi');

$errors = validate_item($nama, $deskripsi);
if (!$errors) {
    try {
        $controller->editItem($item, $nama, $deskripsi, $_FILES['file'] ?? null);
        flash('"' . $nama . '" berhasil diubah.');
        redirect('main/v_edit.php');
    } catch (UploadError $e) {
        $errors[] = $e->getMessage();
    }
}

remember_form($errors, ['nama' => $nama, 'deskripsi' => $deskripsi]);
redirect('v_edit/insert.php', ['type' => $type, 'id' => $item['id']]);
