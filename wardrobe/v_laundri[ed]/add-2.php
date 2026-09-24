<?php
// Langkah 2 dari 2: pilih celana & aksesoris, lalu simpan bersama baju dari langkah 1.
require __DIR__ . '/../inc/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect('v_laundri[ed]/add.php');
}

$controller = new c_wardrobe();
$rows = array_values(array_filter($controller->getLaundryCandidates(), fn($row) => $row['jenis'] !== 'baju'));
$selectedBaju = post_list('items');

page_start();
page_header('v_laundri[ed]/add.php', 'Laundri[ed]');
?>
    <div class="center">
        <form class="tengah" action="<?= e(url('v_laundri[ed]/process.php')) ?>" method="post">
            <?= csrf_field() ?>
            <input type="hidden" name="action" value="add">
            <?php foreach ($selectedBaju as $key): ?>
                <input type="hidden" name="items[]" value="<?= e($key) ?>">
            <?php endforeach; ?>
            <div class="header-container">
                <h4>Pilih Celana / Aksesoris mana yang di laundry (<?= count($selectedBaju) ?> baju dipilih)</h4>
            </div>
            <?php
            item_table($rows, [
                'checkbox' => ['items[]', fn(array $row) => $row['jenis'] . ':' . $row['id']],
                'empty' => 'Tidak ada celana atau aksesoris yang bisa dimasukkan ke laundry.',
            ]);
            ?>
            <div class="header-container">
                <input type="submit" value="Simpan" class="back">
            </div>
        </form>
    </div>
<?php page_end(); ?>
