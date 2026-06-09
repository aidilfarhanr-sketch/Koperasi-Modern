<?php
require __DIR__ . '/config.php';

try {
    $user = require_user();
    $a = action();

    if ($a === 'detail') {
        $id = (int)($_GET['id'] ?? $user['member_id'] ?? 0);
        if (!is_admin($user)) $id = (int)$user['member_id'];
        $stmt = db()->prepare("SELECT m.*, u.username, u.role, u.email AS user_email
                               FROM members m JOIN users u ON u.id=m.user_id WHERE m.id=?");
        $stmt->execute([$id]);
        $m = $stmt->fetch();
        if (!$m) fail('Anggota tidak ditemukan', 404);
        ok($m);
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        if (!is_admin($user)) fail('Akses admin diperlukan', 403);
        $in = input();
        $username = trim($in['username'] ?? strtolower(preg_replace('/\s+/', '_', $in['nama_lengkap'] ?? ('user' . time()))));
        $email = trim($in['email'] ?? ($username . '@raresmaju.local'));
        $nama = trim($in['nama_lengkap'] ?? '');
        if (!$nama) fail('Nama lengkap wajib diisi.');

        db()->beginTransaction();
        $hash = password_hash($in['password'] ?? 'Password123!', PASSWORD_BCRYPT);
        $stmt = db()->prepare("INSERT INTO users (username, email, password_hash, role, is_active) VALUES (?, ?, ?, 'member', 1)");
        $stmt->execute([$username, $email, $hash]);
        $uid = (int)db()->lastInsertId();
        $nomor = 'KRM-' . date('Y') . str_pad((string)$uid, 4, '0', STR_PAD_LEFT);

        $stmt = db()->prepare("INSERT INTO members (user_id, nomor_anggota, nama_lengkap, nik, jenis_kelamin, pekerjaan, alamat, kota, provinsi, no_hp, email, tanggal_bergabung, status_keanggotaan)
                               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), 'Aktif')");
        $stmt->execute([
            $uid, $nomor, $nama,
            $in['nik'] ?? ('AUTO' . str_pad((string)$uid, 12, '0', STR_PAD_LEFT)),
            $in['jenis_kelamin'] ?? 'L',
            $in['pekerjaan'] ?? null,
            $in['alamat'] ?? '-',
            $in['kota'] ?? '-',
            $in['provinsi'] ?? '-',
            $in['no_hp'] ?? '',
            $email
        ]);
        db()->commit();
        ok(['id' => (int)db()->lastInsertId(), 'nomor_anggota' => $nomor], 'Anggota berhasil ditambahkan');
    }

    $search = trim($_GET['search'] ?? $_GET['q'] ?? '');
    $params = [];
    $where = "WHERE 1=1";
    if ($search !== '') {
        $where .= " AND (m.nama_lengkap LIKE ? OR m.nomor_anggota LIKE ? OR m.no_hp LIKE ?)";
        $like = "%$search%";
        $params = [$like, $like, $like];
    }
    $stmt = db()->prepare("SELECT m.*,
      COALESCE((SELECT SUM(jumlah) FROM savings s WHERE s.member_id=m.id AND s.status='Berhasil'),0) AS total_simpanan,
      COALESCE((SELECT SUM(outstanding) FROM loans l WHERE l.member_id=m.id AND l.status IN ('Aktif','Disetujui','Dicairkan','Macet')),0) AS total_pinjaman
      FROM members m $where ORDER BY m.id DESC LIMIT 100");
    $stmt->execute($params);
    ok($stmt->fetchAll());
} catch (Throwable $e) {
    if (db()->inTransaction()) db()->rollBack();
    fail('Members error: ' . $e->getMessage(), 500);
}
