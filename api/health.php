<?php
require __DIR__ . '/config.php';
try {
    db()->query("SELECT 1");
    ok(['php' => PHP_VERSION, 'database' => DB_NAME], 'API dan database terkoneksi');
} catch (Throwable $e) {
    fail('Koneksi database gagal: ' . $e->getMessage(), 500);
}
