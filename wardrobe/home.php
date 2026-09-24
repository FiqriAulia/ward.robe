<?php
define('PUBLIC_PAGE', true);
require __DIR__ . '/inc/bootstrap.php';

page_start();
?>
    <div class="center">
        <div class="wardrobe">
            <h1 id="egg">Wardrobe</h1>
        </div>
        <div class="box"><!-- Wizart -->
            <div class="wiz">
                <div class="overlap-group">
                    <div class="rectangle"></div>
                    <img class="sleep" src="<?= e(url('asset/Sleep.png')) ?>" alt="Wizard sedang tidur">
                </div>
            </div>
        </div>
        <a class="button" href="<?= e(url('v_menu.php')) ?>">
            <h3>Wake the Wizard</h3>
        </a>
    </div>
<?php page_end(); ?>
