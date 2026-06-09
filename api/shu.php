<?php
require __DIR__ . '/config.php';

try {
    $user = require_user();
    $a = action();
    if ($a === 'my') {
        $memberId = (int)($user['member_id'] ?? 0);
        if (!$memberId) fail('Member tidak ditemukan', 404);
        $stmt = db()->prepare("SELECT periode_tahun AS tahun, total_shu, total_shu AS bagian_anggota, status
                               FROM shu_distributions WHERE member_id=? ORDER BY periode_tahun DESC");
        $stmt->execute([$memberId]);
        $rows = $stmt->fetchAll();
        $latest = $rows[0] ?? ['tahun' => (int)date('Y')-1, 'total_shu' => 0, 'bagian_anggota' => 0, 'status' => 'Belum tersedia'];
        $latest['riwayat'] = $rows;
        ok($latest);
    }
    fail('Action SHU tidak dikenal.');
} catch (Throwable $e) {
    fail('SHU error: ' . $e->getMessage(), 500);
}
