<?php
require __DIR__ . '/config.php';

try {
    $user = require_user();
    $a = action();
    $memberId = (int)($user['member_id'] ?? 0);

    if ($a === 'saldo') {
        $params = [];
        $where = "WHERE s.status='Berhasil'";
        if (!is_admin($user)) { $where .= " AND s.member_id=?"; $params[] = $memberId; }

        $stmt = db()->prepare("SELECT s.jenis_simpanan, COALESCE(SUM(s.jumlah),0) AS saldo, COALESCE(SUM(s.jumlah),0) AS saldo_terakhir
                               FROM savings s $where GROUP BY s.jenis_simpanan");
        $stmt->execute($params);
        $per = $stmt->fetchAll();
        $total = array_sum(array_map(fn($r) => (float)$r['saldo'], $per));
        ok(['total' => $total, 'total_saldo' => $total, 'per_jenis' => $per]);
    }

    if ($a === 'list') {
        $params = [];
        $where = "WHERE 1=1";
        if (!is_admin($user)) { $where .= " AND s.member_id=?"; $params[] = $memberId; }
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $stmt = db()->prepare("SELECT s.*, m.nama_lengkap, m.nomor_anggota
                               FROM savings s JOIN members m ON m.id=s.member_id
                               $where ORDER BY s.tanggal_transaksi DESC, s.id DESC LIMIT $limit");
        $stmt->execute($params);
        ok($stmt->fetchAll());
    }

    if ($a === 'setor') {
        $in = input();
        $targetMember = is_admin($user) && !empty($in['member_id']) ? (int)$in['member_id'] : $memberId;
        if (!$targetMember) fail('Member tidak valid.');

        $jenis = str_replace('Simpanan ', '', trim($in['jenis_simpanan'] ?? 'Wajib'));
        if (!in_array($jenis, ['Pokok','Wajib','Sukarela','Berjangka','Hari Raya'], true)) $jenis = 'Wajib';
        $jumlah = (float)($in['jumlah'] ?? 0);
        if ($jumlah < 1000) fail('Jumlah simpanan minimal Rp 1.000.');

        $stmt = db()->prepare("SELECT COALESCE(SUM(jumlah),0) FROM savings WHERE member_id=? AND jenis_simpanan=? AND status='Berhasil'");
        $stmt->execute([$targetMember, $jenis]);
        $saldo = (float)$stmt->fetchColumn() + $jumlah;

        $ref = 'SV-' . date('YmdHis') . '-' . rand(100,999);
        $stmt = db()->prepare("INSERT INTO savings (member_id, jenis_simpanan, jumlah, saldo_setelah, keterangan, referensi_no, tanggal_transaksi, status, approved_by, approved_at)
                               VALUES (?, ?, ?, ?, ?, ?, ?, 'Berhasil', ?, NOW())");
        $stmt->execute([
            $targetMember, $jenis, $jumlah, $saldo,
            $in['keterangan'] ?? 'Setoran via aplikasi',
            $ref,
            $in['tanggal_transaksi'] ?? date('Y-m-d'),
            $user['user_id']
        ]);
        $id = (int)db()->lastInsertId();
        upload_doc($targetMember, $id, 'savings', 'bukti', 'Bukti Simpanan');
        log_activity((int)$user['user_id'], 'Setor', 'Simpanan', "Setor $jenis sebesar $jumlah");
        ok(['id' => $id, 'referensi_no' => $ref, 'saldo_baru' => $saldo], 'Simpanan berhasil dicatat');
    }

    fail('Action savings tidak dikenal.');
} catch (Throwable $e) {
    fail('Savings error: ' . $e->getMessage(), 500);
}
