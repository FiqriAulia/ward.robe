<?php
require __DIR__ . '/../inc/bootstrap.php';

$controller = new c_wardrobe();
$rows = $controller->getAllLaundryData();

page_start();
page_header('v_menu.php', 'Laundri[ed]');
?>
    <div class="center">
        <div class="tengah">
            <div class="header-container">
                <h4>Berikut pakaian yang sedang di laundry</h4>
            </div>
            <?php item_table($rows, ['empty' => 'Tidak ada pakaian di laundry.']); ?>
            <div class="header-container">
                <h4 class="add"><a href="<?= e(url('v_laundri[ed]/add.php')) ?>">Masukkan Laundry-an Baru</a></h4>
                <h4 class="remove"><a href="<?= e(url('v_laundri[ed]/remove.php')) ?>">Sudah Selesai?</a></h4>
            </div>
        </div>
    </div>
<?php page_end(); ?>
