<?php
require __DIR__ . '/config.php';

try {
    $user = require_user();
    $a = action();

    if ($a === 'list' || $a === 'jatuh_tempo') {
        $params = [];
        $where = "WHERE 1=1";
        if (!is_admin($user)) { $where .= " AND i.member_id=?"; $params[] = (int)$user['member_id']; }
        if (!empty($_GET['loan_id'])) { $where .= " AND i.loan_id=?"; $params[] = (int)$_GET['loan_id']; }
        if ($a === 'jatuh_tempo') { $where .= " AND i.status<>'Lunas'"; }
        $stmt = db()->prepare("SELECT i.*, l.nomor_pinjaman, m.nama_lengkap, m.nomor_anggota,
                                      DATEDIFF(i.tanggal_jatuh_tempo, CURDATE()) AS sisa_hari
                               FROM installments i
                               JOIN loans l ON l.id=i.loan_id
                               JOIN members m ON m.id=i.member_id
                               $where
                               ORDER BY i.tanggal_jatuh_tempo ASC, i.id ASC LIMIT 100");
        $stmt->execute($params);
        ok($stmt->fetchAll());
    }

    if ($a === 'bayar') {
        $user = require_user();
        $id = (int)($_GET['id'] ?? 0);
        $in = input();

        $stmt = db()->prepare("SELECT * FROM installments WHERE id=?");
        $stmt->execute([$id]);
        $ins = $stmt->fetch();
        if (!$ins) fail('Cicilan tidak ditemukan', 404);
        if (!is_admin($user) && (int)$ins['member_id'] !== (int)$user['member_id']) fail('Tidak boleh membayar cicilan anggota lain', 403);

        db()->beginTransaction();
        $denda = (float)($in['jumlah_denda'] ?? 0);
        $total = (float)$ins['total_bayar'] + $denda;
        $metode = $in['metode_bayar'] ?? 'Transfer';
        if (!in_array($metode, ['Tunai','Transfer','Potong Simpanan','Lainnya'], true)) $metode = 'Transfer';

        db()->prepare("UPDATE installments SET status='Lunas', tanggal_bayar=?, jumlah_denda=?, total_bayar=?, metode_bayar=?, referensi_bayar=?, dibayar_ke=? WHERE id=?")
            ->execute([
                $in['tanggal_bayar'] ?? date('Y-m-d'),
                $denda,
                $total,
                $metode,
                $in['referensi_bayar'] ?? null,
                (int)$user['user_id'],
                $id
            ]);

        db()->prepare("UPDATE loans SET outstanding = GREATEST(outstanding - ?, 0) WHERE id=?")
            ->execute([(float)$ins['jumlah_pokok'], (int)$ins['loan_id']]);

        $stmt = db()->prepare("SELECT outstanding FROM loans WHERE id=?");
        $stmt->execute([(int)$ins['loan_id']]);
        $outstanding = (float)$stmt->fetchColumn();
        $lunas = $outstanding <= 0;
        if ($lunas) {
            db()->prepare("UPDATE loans SET status='Lunas', tanggal_lunas=CURDATE() WHERE id=?")->execute([(int)$ins['loan_id']]);
        }

        db()->commit();
        log_activity((int)$user['user_id'], 'Bayar', 'Cicilan', "Bayar cicilan #$id");
        ok(['id' => $id, 'total_dibayar' => $total, 'pinjaman_lunas' => $lunas], 'Cicilan berhasil dibayar');
    }

    fail('Action installments tidak dikenal.');
} catch (Throwable $e) {
    if (db()->inTransaction()) db()->rollBack();
    fail('Installments error: ' . $e->getMessage(), 500);
}
