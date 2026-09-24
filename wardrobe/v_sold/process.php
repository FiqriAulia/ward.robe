<?php
require __DIR__ . '/../inc/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect('main/v_sold.php');
}

$controller = new c_wardrobe();
$type = $controller->requireType($_POST['type'] ?? null);
$sold = $controller->sellItems($type, post_list('ids'));

flash($sold > 0 ? "$sold " . c_wardrobe::label($type) . ' terjual.' : 'Tidak ada pakaian yang dipilih.');
redirect('main/v_sold.php');
