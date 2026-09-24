<?php
require __DIR__ . '/../inc/bootstrap.php';

$controller = new c_wardrobe();
$rows = $controller->getAllData();

page_start();
page_header('v_menu.php', 'Edit');
?>
    <div class="center">
        <?php
        item_table($rows, [
            'empty' => 'Belum ada pakaian untuk diedit.',
            'action' => fn(array $row) => '<a class="back" href="'
                . e(url('v_edit/insert.php', ['type' => $row['jenis'], 'id' => $row['id']])) . '">Edit</a>',
        ]);
        ?>
    </div>
<?php page_end(); ?>
