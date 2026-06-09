<?php
require __DIR__ . '/config.php';

try {
    $user = require_user();
    $a = action();
    if ($a !== 'list') fail('Action transactions tidak dikenal.');

    $params = [];
    $where = 'WHERE 1=1';
    if (!is_admin($user)) { $where .= ' AND t.member_id=?'; $params[] = (int)$user['member_id']; }
    if (!empty($_GET['member_id']) && is_admin($user)) { $where .= ' AND t.member_id=?'; $params[] = (int)$_GET['member_id']; }
    if (!empty($_GET['referensi_tabel'])) { $where .= ' AND t.referensi_tabel=?'; $params[] = $_GET['referensi_tabel']; }
    if (!empty($_GET['referensi_id'])) { $where .= ' AND t.referensi_id=?'; $params[] = (int)$_GET['referensi_id']; }
    $limit = max(1, min(100, (int)($_GET['limit'] ?? 50)));

    $stmt = db()->prepare("SELECT t.*, m.nama_lengkap, m.nomor_anggota
                           FROM transactions t
                           LEFT JOIN members m ON m.id=t.member_id
                           $where ORDER BY t.tanggal DESC, t.id DESC LIMIT $limit");
    $stmt->execute($params);
    ok($stmt->fetchAll());
} catch (Throwable $e) {
    fail('Transactions error: ' . $e->getMessage(), 500);
}
