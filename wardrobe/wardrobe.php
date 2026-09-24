<?php
// Easter egg: klik judul "Wardrobe" di home 3x.
define('PUBLIC_PAGE', true);
require __DIR__ . '/inc/bootstrap.php';

$changelog = file_get_contents(APP_ROOT . '/asset/txt/changelog.txt');

page_start('Wardrobe', 'egg-page');
?>
    <div class="egg">
        <pre><?= e($changelog) ?></pre>
    </div>
<?php page_end(); ?>
