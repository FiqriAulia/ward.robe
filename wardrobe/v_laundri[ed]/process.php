<?php
require __DIR__ . '/../inc/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect('main/v_laundri[ed].php');
}

$controller = new c_wardrobe();

switch ($_POST['action'] ?? '') {
    case 'add':
        $added = $controller->addToLaundry(post_list('items'));
        flash($added > 0 ? "$added pakaian masuk laundry." : 'Tidak ada pakaian yang dipilih.');
        break;
    case 'remove':
        $removed = $controller->removeFromLaundry(post_list('laundry_ids'));
        flash($removed > 0 ? "$removed pakaian selesai di laundry." : 'Tidak ada pakaian yang dipilih.');
        break;
}

redirect('main/v_laundri[ed].php');
