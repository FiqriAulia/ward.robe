<?php
require __DIR__ . '/../inc/bootstrap.php';

$controller = new c_wardrobe();
$rows = $controller->getAllLaundryData();

page_start();
page_header('main/v_laundri[ed].php', 'Laundri[ed]');
?>
    <div class="center">
        <form class="tengah" action="<?= e(url('v_laundri[ed]/process.php')) ?>" method="post">
            <?= csrf_field() ?>
            <input type="hidden" name="action" value="remove">
            <div class="header-container">
                <h4>Pilih pakaian mana yang sudah selesai di laundry</h4>
            </div>
            <?php
            item_table($rows, [
                'checkbox' => ['laundry_ids[]', fn(array $row) => (string) $row['LAUNDRY_ID']],
                'empty' => 'Tidak ada pakaian di laundry.',
            ]);
            ?>
            <div class="header-container">
                <input type="submit" value="Selesai" class="back">
            </div>
        </form>
    </div>
<?php page_end(); ?>
