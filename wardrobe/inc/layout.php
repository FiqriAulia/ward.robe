<?php
// Potongan HTML yang dipakai bersama oleh semua halaman.

function page_start(string $title = 'Wardrobe', string $bodyClass = ''): void
{
    ?>
<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($title) ?></title>
    <link rel="stylesheet" href="<?= e(url('styles.css')) ?>">
    <script src="<?= e(url('jquery/jquery-3.7.1.min.js')) ?>"></script>
    <script src="<?= e(url('jquery/script.js')) ?>"></script>
</head>

<body class="<?= e($bodyClass) ?>" data-base="<?= e(BASE) ?>">
    <?php foreach (take_flashes() as $flash): ?>
        <div class="flash flash-<?= e($flash['type']) ?>"><?= e($flash['message']) ?></div>
    <?php endforeach; ?>
    <?php
}

function page_end(): void
{
    echo "\n</body>\n\n</html>\n";
}

/** Header dengan tombol Back di kiri dan judul di kanan. $extraHtml harus sudah di-escape. */
function page_header(string $backPath, string $heading, string $extraHtml = ''): void
{
    ?>
    <header class="header-container">
        <a class="back" href="<?= e(url($backPath)) ?>">Back</a>
        <?= $extraHtml ?>
        <h3><?= e($heading) ?></h3>
    </header>
    <?php
}

function wizard_awake(): void
{
    ?>
    <div class="box"><!-- Wizart -->
        <div class="wiz">
            <div class="overlap-group">
                <div class="rectangle"></div>
                <main>
                    <img class="wake" id="anchor" src="<?= e(url('asset/Wake.png')) ?>" alt="Wizard">
                    <div id="eyes">
                        <img class="eye" src="<?= e(url('asset/Mata.png')) ?>" alt="" style="top: 240px;left: 35px;">
                        <img class="eye" src="<?= e(url('asset/Mata.png')) ?>" alt="" style="top: 240px;left: -52px;">
                    </div>
                </main>
            </div>
        </div>
    </div>
    <?php
}

/** <img> foto pakaian, atau string kosong bila fotonya tidak ada. */
function image_tag(?string $foto): string
{
    if (image_path($foto) === null) {
        return '';
    }
    return '<img class="foto" src="' . e(image_url($foto)) . '" alt="">';
}

/**
 * Tabel daftar pakaian. Setiap baris minimal punya kolom nama, deskripsi, foto
 * (dan jenis bila $options['jenis'] true).
 *
 * $options:
 *   'jenis'    => bool, tampilkan kolom Jenis (default true)
 *   'checkbox' => [nama input, fn(array $row): string nilai], kolom checkbox di kiri
 *   'action'   => fn(array $row): string HTML (sudah di-escape), kolom di kanan
 *   'empty'    => pesan bila tidak ada data
 */
function item_table(array $rows, array $options = []): void
{
    $showJenis = $options['jenis'] ?? true;
    $checkbox = $options['checkbox'] ?? null;
    $action = $options['action'] ?? null;
    $empty = $options['empty'] ?? 'Belum ada pakaian.';
    ?>
    <table>
        <thead>
            <tr>
                <?php if ($checkbox): ?><th class="small"></th><?php endif; ?>
                <th class="small">No</th>
                <?php if ($showJenis): ?><th class="jenis">Jenis</th><?php endif; ?>
                <th>Nama</th>
                <th>Deskripsi</th>
                <th>Foto</th>
                <?php if ($action): ?><th class="small"></th><?php endif; ?>
            </tr>
        </thead>
        <tbody>
            <?php if (!$rows): ?>
                <tr class="empty"><td><?= e($empty) ?></td></tr>
            <?php endif; ?>
            <?php foreach ($rows as $i => $row): ?>
                <tr>
                    <?php if ($checkbox): ?>
                        <td class="small">
                            <input type="checkbox" name="<?= e($checkbox[0]) ?>" value="<?= e($checkbox[1]($row)) ?>"
                                aria-label="Pilih <?= e($row['nama']) ?>">
                        </td>
                    <?php endif; ?>
                    <td class="small"><?= $i + 1 ?></td>
                    <?php if ($showJenis): ?><td class="jenis"><?= e(c_wardrobe::label($row['jenis'])) ?></td><?php endif; ?>
                    <td><?= e($row['nama']) ?></td>
                    <td><?= nl2br(e($row['deskripsi'])) ?></td>
                    <td class="fotoble"><?= image_tag($row['foto']) ?></td>
                    <?php if ($action): ?><td class="small"><?= $action($row) ?></td><?php endif; ?>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    <?php
}

/** Daftar pesan error validasi. */
function error_list(array $errors): void
{
    if (!$errors) {
        return;
    }
    echo '<ul class="errors">';
    foreach ($errors as $error) {
        echo '<li>' . e($error) . '</li>';
    }
    echo '</ul>';
}

function render_message_page(string $heading, string $message): void
{
    page_start($heading);
    ?>
    <div class="center">
        <div class="message">
            <h2><?= e($heading) ?></h2>
            <p><?= e($message) ?></p>
            <p><a class="back" href="<?= e(url('home.php')) ?>">Kembali ke awal</a></p>
        </div>
    </div>
    <?php
    page_end();
}

function render_install_page(): void
{
    page_start('Install Wardrobe');
    ?>
    <div class="center">
        <div class="message">
            <h2>Install Database Dulu</h2>
            <p>Database belum bisa diakses. Ikuti <a href="<?= e(url('asset/txt/install.txt')) ?>">langkah instalasi</a>.</p>
        </div>
    </div>
    <?php
    page_end();
}
