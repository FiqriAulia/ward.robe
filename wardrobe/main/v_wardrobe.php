<?php
require __DIR__ . '/../inc/bootstrap.php';

$controller = new c_wardrobe();
$rows = $controller->getAllData();

page_start();
page_header('v_menu.php', 'Wardrobe');
?>
    <div class="center">
        <?php item_table($rows, ['empty' => 'Lemari masih kosong. Tambahkan pakaian lewat menu Input.']); ?>
    </div>
<?php page_end(); ?>
