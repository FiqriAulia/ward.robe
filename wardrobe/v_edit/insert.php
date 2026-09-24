<?php
require __DIR__ . '/../inc/bootstrap.php';

$controller = new c_wardrobe();
$type = $controller->requireType($_GET['type'] ?? null);
$item = $controller->requireItem($type, $_GET['id'] ?? null);
$form = take_form();
$old = $form['old'] + $item;

page_start();
page_header('main/v_edit.php', c_wardrobe::label($type));
?>
    <div class="center">
        <div class="menukiri">
            <?php wizard_awake(); ?>
        </div>
        <div class="menukanan">
            <form action="<?= e(url('v_edit/process.php')) ?>" method="post" class="container" enctype="multipart/form-data">
                <?= csrf_field() ?>
                <input type="hidden" name="type" value="<?= e($type) ?>">
                <input type="hidden" name="id" value="<?= e($item['id']) ?>">
                <?php error_list($form['errors']); ?>
                <label for="nomor">Nomor :</label>
                <input type="text" class="nama" id="nomor" value="<?= e($item['id']) ?>" readonly>
                <label for="nama">Nama :</label>
                <input type="text" class="nama" id="nama" name="nama" maxlength="255" required value="<?= e($old['nama']) ?>">
                <label for="deskripsi">Deskripsi :</label>
                <textarea id="deskripsi" name="deskripsi" class="deskripsi" cols="30" rows="10" maxlength="5000"
                    required><?= e($old['deskripsi']) ?></textarea>

                <div class="current-photo">
                    <?= image_tag($item['foto']) ?>
                    <span>Kosongkan file bila foto tidak diganti.</span>
                </div>
                <div class="form-actions">
                    <input type="file" class="file" name="file" accept="image/jpeg,image/png,image/gif,image/webp">
                    <input type="submit" value="Submit">
                </div>
            </form>
        </div>
    </div>
<?php page_end(); ?>
