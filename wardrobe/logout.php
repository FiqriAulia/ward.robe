<?php
define('PUBLIC_PAGE', true);
require __DIR__ . '/inc/bootstrap.php';

// Hanya lewat POST (dengan CSRF token), supaya tidak bisa dipicu dari link luar.
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $_SESSION = [];
    session_destroy();
    redirect('home.php');
}

redirect('v_menu.php');
