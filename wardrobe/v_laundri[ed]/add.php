<?php
// Langkah 1 dari 2: pilih baju yang masuk laundry.
require __DIR__ . '/../inc/bootstrap.php';

$controller = new c_wardrobe();
$rows = array_values(array_filter($controller->getLaundryCandidates(), fn($row) => $row['jenis'] === 'baju'));

page_start();
page_header('main/v_laundri[ed].php', 'Laundri[ed]');
?>
    <div class="center">
        <form class="tengah" action="<?= e(url('v_laundri[ed]/add-2.php')) ?>" method="post">
            <?= csrf_field() ?>
            <div class="header-container">
                <h4>Pilih Baju mana yang di laundry</h4>
            </div>
            <?php
            item_table($rows, [
                'jenis' => false,
                'checkbox' => ['items[]', fn(array $row) => $row['jenis'] . ':' . $row['id']],
                'empty' => 'Tidak ada baju yang bisa dimasukkan ke laundry.',
            ]);
            ?>
            <div class="header-container">
                <input type="submit" value="Lanjut" class="back">
            </div>
        </form>
    </div>
<?php page_end(); ?>
