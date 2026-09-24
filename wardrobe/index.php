<?php
define('PUBLIC_PAGE', true);
require __DIR__ . '/inc/bootstrap.php';

db(); // Tampilkan halaman instalasi kalau database belum siap.

page_start('Wardrobe', 'landing');
?>
    <div class="center">
        <img class="wizard" src="<?= e(url('asset/Rizzard.png')) ?>" alt="The Rizzard">
    </div>
<?php page_end(); ?>
