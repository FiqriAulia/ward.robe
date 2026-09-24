<?php
require __DIR__ . '/../inc/bootstrap.php';

$controller = new c_wardrobe();
$rows = $controller->dressMe();

page_start();
page_header('v_menu.php', 'Dress Me', '<a class="gen" href="' . e(url('v_dressme/process.php')) . '">Re-generate</a>');
?>
    <div class="center">
        <div class="menukiri">
            <?php wizard_awake(); ?>
        </div>
        <div class="wardrobe">
            <?php if (!$rows): ?>
                <p>Yah kamu gaada pakaian yang bisa dipakai.<br>Tambah lewat menu Input, atau tunggu laundry-an selesai.</p>
            <?php else: ?>
                <?php foreach (array_chunk($rows, 2) as $pair): ?>
                    <div class="kotak">
                        <?php foreach ($pair as $row): ?>
                            <?php $path = image_path($row['foto']); ?>
                            <div class="lazy" title="<?= e(c_wardrobe::label($row['jenis']) . ': ' . $row['nama']) ?>"
                                <?php if ($path !== null): ?>style="background-image: url('<?= e(image_url($row['foto'])) ?>');"<?php endif; ?>>
                                <?php if ($path === null): ?><span><?= e($row['nama']) ?></span><?php endif; ?>
                            </div>
                        <?php endforeach; ?>
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </div>
<?php page_end(); ?>
