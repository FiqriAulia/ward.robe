<?php
require __DIR__ . '/../inc/bootstrap.php';

$controller = new c_wardrobe();
$type = $controller->requireType($_GET['type'] ?? null);
$label = c_wardrobe::label($type);
$form = take_form();
$old = $form['old'];

page_start();
page_header('main/v_input.php', $label);
?>
    <div class="center">
        <div class="menukiri">
            <?php wizard_awake(); ?>
        </div>
        <div class="menukanan">
            <form action="<?= e(url('v_input/process.php')) ?>" method="post" class="container" enctype="multipart/form-data">
                <?= csrf_field() ?>
                <input type="hidden" name="type" value="<?= e($type) ?>">
                <?php error_list($form['errors']); ?>
                <label for="nama">Nama :</label>
                <input type="text" class="nama" id="nama" name="nama" maxlength="255" required
                    value="<?= e($old['nama'] ?? '') ?>" placeholder="Dapat berupa merk <?= e($label) ?>">
                <label for="deskripsi">Deskripsi :</label>
                <textarea id="deskripsi" name="deskripsi" class="deskripsi" cols="30" rows="10" maxlength="5000" required
                    placeholder="Isi deskripsi ini dengan sesuatu yang unik dari <?= e($label) ?> tersebut"><?= e($old['deskripsi'] ?? '') ?></textarea>

                <div class="form-actions">
                    <input type="file" class="file" name="file" accept="image/jpeg,image/png,image/gif,image/webp" required>
                    <input type="submit" value="Submit">
                </div>
            </form>
        </div>
    </div>
<?php page_end(); ?>
