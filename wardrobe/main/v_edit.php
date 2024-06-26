<?php
include_once("../c_wardrobe.php");

$controller = new c_wardrobe();
$rows = $controller->getAllData();
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wardrobe</title>
    <link rel="stylesheet" href="../styles.css">
    <script src="../jquery/jquery-3.7.1.min.js"></script>
    <script src="../jquery/script.js"></script>
</head>

<body>
    <header class="header-container">
        <form action="../v_menu.php" method="get" class="form-back">
            <input class="back" type="submit" value="Back">
        </form>
        <h3>Edit</h3>
    </header>
    <div class="center">
        <table>
            <thead>
                <tr>
                    <th class="small">No</th>
                    <th class="jenis">Jenis</th>
                    <th>Nama</th>
                    <th>Deskripsi</th>
                    <th>Foto</th>
                    <th class="small"></th>
                </tr>
            </thead>
            <tbody>
                <?php
                $no = 1;
                foreach ($rows as $rowItem):
                    ?>
                    <tr>
                        <td class="small">
                            <?= $no ?>
                        </td>
                        <td class="jenis">
                            <?= $rowItem['jenis'] ?>
                        </td>
                        <td>
                            <?= $rowItem['nama'] ?>
                        </td>
                        <td>
                            <?= $rowItem['deskripsi'] ?>
                        </td>
                        <td class="fotoble">
                            <img class="foto" src="../gambar/<?=  $rowItem['foto'] ?>" alt="">
                        </td>
                        <td class="small">
                            <form action='../v_edit/insert.php' method='POST'>
                                <input name='jenis' type='hidden' value="<?= $rowItem['jenis']; ?>">
                                <input name='nama' type='hidden' value="<?= $rowItem['nama']; ?>">
                                <input name='deskripsi' type='hidden' value="<?= $rowItem['deskripsi']; ?>">
                                <input name='foto' type='hidden' value="<?= $rowItem['foto']; ?>">
                                <button type='submit' name='button' value='<?php echo $rowItem['id']?>'>Edit</button>
                            </form>
                        </td>
                    </tr>
                    <?php $no += 1; ?>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>

</html>