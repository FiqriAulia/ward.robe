<?php
require __DIR__ . '/../inc/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect('main/v_input.php');
}

$controller = new c_wardrobe();
$type = $controller->requireType($_POST['type'] ?? null);
$nama = post_text('nama');
$deskripsi = post_text('deskripsi');

$errors = validate_item($nama, $deskripsi);
if (!$errors) {
    try {
        $controller->addItem($type, $nama, $deskripsi, $_FILES['file'] ?? []);
        flash(c_wardrobe::label($type) . ' "' . $nama . '" berhasil ditambahkan.');
        redirect('main/v_input.php');
    } catch (UploadError $e) {
        $errors[] = $e->getMessage();
    }
}

remember_form($errors, ['nama' => $nama, 'deskripsi' => $deskripsi]);
redirect('v_input/insert.php', ['type' => $type]);
