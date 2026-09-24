<?php
require __DIR__ . '/inc/bootstrap.php';

page_start();
?>
    <form class="logout" action="<?= e(url('logout.php')) ?>" method="post">
        <?= csrf_field() ?>
        <input class="back" type="submit" value="Logout">
    </form>
    <div class="center">
        <div class="menukiri">
            <h2 class="input"><a href="<?= e(url('main/v_input.php')) ?>">Input</a></h2>
            <h2 class="londi"><a href="<?= e(url('main/v_laundri[ed].php')) ?>">Laundri[ed]</a></h2>
            <h2 class="edit"><a href="<?= e(url('main/v_edit.php')) ?>">Edit</a></h2>
        </div>
        <?php wizard_awake(); ?>
        <div class="menukanan">
            <h2 class="sold"><a href="<?= e(url('main/v_sold.php')) ?>">Sold</a></h2>
            <h2 class="wardrobe"><a href="<?= e(url('main/v_wardrobe.php')) ?>">Wardrobe</a></h2>
            <h2 class="dressme"><a href="<?= e(url('main/v_dress me.php')) ?>">Dress Me</a></h2>
        </div>
    </div>
<?php page_end(); ?>
