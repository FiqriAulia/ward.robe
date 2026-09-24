<?php
require __DIR__ . '/../inc/bootstrap.php';

page_start();
?>
    <div class="center">
        <div class="menukiri">
            <div><a class="btn" href="<?= e(url('v_input/insert.php', ['type' => 'baju'])) ?>">Baju</a></div>
            <div class="invis" aria-hidden="true">Laundri[ed]</div>
            <div><a class="btn" href="<?= e(url('v_input/insert.php', ['type' => 'celana'])) ?>">Celana</a></div>
        </div>
        <?php wizard_awake(); ?>
        <div class="menukanan">
            <div><a class="btn" href="<?= e(url('v_input/insert.php', ['type' => 'aksesoris'])) ?>">Aksesoris</a></div>
            <div class="invis" aria-hidden="true">Wardrobe</div>
            <div><a class="btn" href="<?= e(url('v_menu.php')) ?>">Back</a></div>
        </div>
    </div>
<?php page_end(); ?>
