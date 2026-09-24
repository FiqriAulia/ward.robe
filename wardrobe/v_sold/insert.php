<?php
require __DIR__ . '/../inc/bootstrap.php';

$controller = new c_wardrobe();
$type = $controller->requireType($_GET['type'] ?? null);
$label = c_wardrobe::label($type);
$rows = $controller->getByType($type);

page_start();
page_header('main/v_sold.php', 'Sold');
?>
    <div class="center">
        <form class="tengah" action="<?= e(url('v_sold/process.php')) ?>" method="post"
            data-confirm="Yakin? <?= e($label) ?> yang dipilih akan dihapus permanen beserta fotonya.">
            <?= csrf_field() ?>
            <input type="hidden" name="type" value="<?= e($type) ?>">
            <div class="header-container">
                <h4>Pilih <?= e($label) ?> mana yang sudah dijual</h4>
            </div>
            <?php
            item_table($rows, [
                'jenis' => false,
                'checkbox' => ['ids[]', fn(array $row) => (string) $row['id']],
                'empty' => "Tidak ada $label.",
            ]);
            ?>
            <div class="header-container">
                <input type="submit" value="Sold ??" class="back">
            </div>
        </form>
    </div>
<?php page_end(); ?>
