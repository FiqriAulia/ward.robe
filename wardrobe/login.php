<?php
define('PUBLIC_PAGE', true);
require __DIR__ . '/inc/bootstrap.php';

if (is_logged_in()) {
    redirect('v_menu.php');
}

$controller = new c_wardrobe();
$hash = $controller->passwordHash();
$isSetup = $hash === null;
$errors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $password = $_POST['password'] ?? '';
    $password = is_string($password) ? $password : '';

    if ($isSetup) {
        $confirm = $_POST['password_confirm'] ?? '';
        if (strlen($password) < 8) {
            $errors[] = 'Password minimal 8 karakter.';
        } elseif (!is_string($confirm) || !hash_equals($password, $confirm)) {
            $errors[] = 'Konfirmasi password tidak sama.';
        } elseif (!$controller->setInitialPassword($password)) {
            $errors[] = 'Password sudah dibuat sebelumnya. Silakan login.';
            $isSetup = false;
        } else {
            log_in();
            flash('Password tersimpan. Selamat datang!');
            redirect('v_menu.php');
        }
    } elseif (password_verify($password, $hash)) {
        if (password_needs_rehash($hash, PASSWORD_DEFAULT)) {
            $controller->rehashPassword($password);
        }
        log_in();
        redirect('v_menu.php');
    } else {
        sleep(1); // Perlambat tebak-tebakan password.
        $errors[] = 'Password salah.';
    }
}

page_start('Login - Wardrobe');
?>
    <div class="center">
        <div class="menukiri">
            <?php wizard_awake(); ?>
        </div>
        <div class="menukanan">
            <form action="<?= e(url('login.php')) ?>" method="post" class="container">
                <?= csrf_field() ?>
                <?php if ($isSetup): ?>
                    <h3>Buat Password</h3>
                    <p>Belum ada password. Buat password untuk melindungi wardrobe kamu.</p>
                <?php else: ?>
                    <h3>Login</h3>
                <?php endif; ?>
                <?php error_list($errors); ?>
                <label for="password">Password :</label>
                <input type="password" class="nama" id="password" name="password"
                    autocomplete="<?= $isSetup ? 'new-password' : 'current-password' ?>" required autofocus>
                <?php if ($isSetup): ?>
                    <label for="password_confirm">Ulangi Password :</label>
                    <input type="password" class="nama" id="password_confirm" name="password_confirm"
                        autocomplete="new-password" required>
                <?php endif; ?>
                <input type="submit" value="<?= $isSetup ? 'Simpan' : 'Masuk' ?>">
            </form>
        </div>
    </div>
<?php page_end(); ?>
