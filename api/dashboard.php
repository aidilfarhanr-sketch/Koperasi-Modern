<?php
require __DIR__ . '/config.php';

try {
    $user = require_user();
    $a = action();

    if ($a === 'admin') {
        if (!is_admin($user)) fail('Akses admin diperlukan', 403);

        $kpi = [
            'total_anggota_aktif' => (int)db()->query("SELECT COUNT(*) FROM members WHERE status_keanggotaan='Aktif'")->fetchColumn(),
            'total_simpanan' => (float)db()->query("SELECT COALESCE(SUM(jumlah),0) FROM savings WHERE status='Berhasil'")->fetchColumn(),
            'total_outstanding_pinjaman' => (float)db()->query("SELECT COALESCE(SUM(outstanding),0) FROM loans WHERE status IN ('Disetujui','Dicairkan','Aktif','Macet')")->fetchColumn(),
            'total_shu_tahun_lalu' => (float)db()->query("SELECT COALESCE(SUM(total_shu),0) FROM shu_distributions WHERE periode_tahun = YEAR(CURDATE())-1")->fetchColumn(),
            'pengajuan_menunggu' => (int)db()->query("SELECT COUNT(*) FROM loans WHERE status='Menunggu'")->fetchColumn(),
        ];

        $pengajuan = db()->query("SELECT l.*, m.nama_lengkap, m.nomor_anggota
                                  FROM loans l JOIN members m ON m.id=l.member_id
                                  ORDER BY l.tanggal_pengajuan DESC, l.id DESC LIMIT 5")->fetchAll();

        $bulanan = db()->query("SELECT DATE_FORMAT(tanggal_transaksi,'%Y-%m') AS bulan,
                                       SUM(CASE WHEN jumlah >= 0 THEN jumlah ELSE 0 END) AS total_setor,
                                       SUM(CASE WHEN jumlah < 0 THEN ABS(jumlah) ELSE 0 END) AS total_tarik
                                FROM savings
                                WHERE tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
                                GROUP BY DATE_FORMAT(tanggal_transaksi,'%Y-%m')
                                ORDER BY bulan")->fetchAll();

        ok(['kpi' => $kpi, 'pengajuan_terbaru' => $pengajuan, 'simpanan_bulanan' => $bulanan]);
    }

    if ($a === 'member') {
        $memberId = (int)($user['member_id'] ?? 0);
        if (!$memberId) fail('Profil member belum tersedia', 404);

        $stmt = db()->prepare("SELECT jenis_simpanan, COALESCE(SUM(jumlah),0) AS saldo, COALESCE(SUM(jumlah),0) AS saldo_terakhir
                               FROM savings WHERE member_id=? AND status='Berhasil'
                               GROUP BY jenis_simpanan");
        $stmt->execute([$memberId]);
        $perJenis = $stmt->fetchAll();
        $total = array_sum(array_map(fn($r) => (float)$r['saldo'], $perJenis));

        $stmt = db()->prepare("SELECT * FROM loans WHERE member_id=? AND status IN ('Disetujui','Dicairkan','Aktif','Macet') ORDER BY id DESC LIMIT 1");
        $stmt->execute([$memberId]);
        $pinjaman = $stmt->fetchAll();

        $stmt = db()->prepare("SELECT * FROM installments WHERE member_id=? AND status<>'Lunas' ORDER BY tanggal_jatuh_tempo ASC LIMIT 1");
        $stmt->execute([$memberId]);
        $cicilan = $stmt->fetchAll();
        foreach ($cicilan as &$c) {
            $c['sisa_hari'] = (int)ceil((strtotime($c['tanggal_jatuh_tempo']) - time()) / 86400);
        }

        $stmt = db()->prepare("SELECT * FROM shu_distributions WHERE member_id=? ORDER BY periode_tahun DESC LIMIT 1");
        $stmt->execute([$memberId]);
        $shu = $stmt->fetch() ?: ['periode_tahun' => (int)date('Y')-1, 'total_shu' => 0, 'status' => 'Belum tersedia'];

        ok([
            'profil' => $user,
            'saldo_simpanan' => ['total' => $total, 'total_saldo' => $total, 'per_jenis' => $perJenis],
            'pinjaman_aktif' => $pinjaman,
            'cicilan_mendatang' => $cicilan,
            'shu' => $shu
        ]);
    }

    fail('Action dashboard tidak dikenal.');
} catch (Throwable $e) {
    fail('Dashboard error: ' . $e->getMessage(), 500);
}
