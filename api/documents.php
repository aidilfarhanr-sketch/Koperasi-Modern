<?php
require __DIR__ . '/config.php';

try {
    $user = require_user();
    $a = action();
    if ($a !== 'list') fail('Action documents tidak dikenal.');

    $params = [];
    $where = 'WHERE 1=1';
    if (!is_admin($user)) { $where .= ' AND d.member_id=?'; $params[] = (int)$user['member_id']; }
    if (!empty($_GET['member_id']) && is_admin($user)) { $where .= ' AND d.member_id=?'; $params[] = (int)$_GET['member_id']; }
    if (!empty($_GET['referensi_tabel'])) { $where .= ' AND d.referensi_tabel=?'; $params[] = $_GET['referensi_tabel']; }
    if (!empty($_GET['referensi_id'])) { $where .= ' AND d.referensi_id=?'; $params[] = (int)$_GET['referensi_id']; }

    $stmt = db()->prepare("SELECT d.*, m.nama_lengkap, m.nomor_anggota
                           FROM documents d
                           JOIN members m ON m.id=d.member_id
                           $where ORDER BY d.uploaded_at DESC, d.id DESC LIMIT 100");
    $stmt->execute($params);
    $docs = $stmt->fetchAll();
    foreach ($docs as &$d) {
        $path = (string)($d['path_file'] ?? '');
        $name = (string)($d['nama_simpan'] ?? '');
        if ($path !== '' && substr($path, -1) === '/' && $name !== '') $path .= $name;
        $d['url'] = $path;
    }
    ok($docs);
} catch (Throwable $e) {
    fail('Documents error: ' . $e->getMessage(), 500);
}
