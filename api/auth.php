<?php
require __DIR__ . '/config.php';

try {
    $a = action();
    $in = input();

    if ($a === 'login') {
        $username = trim($in['username'] ?? $in['email'] ?? '');
        $password = (string)($in['password'] ?? '');

        if ($username === '' || $password === '') fail('Username dan password wajib diisi.');

        $stmt = db()->prepare("SELECT * FROM users WHERE (username = ? OR email = ?) AND is_active = 1 LIMIT 1");
        $stmt->execute([$username, $username]);
        $u = $stmt->fetch();
        if (!$u) fail('Username tidak ditemukan.', 401);
        $valid = password_verify($password, $u['password_hash']);

        if (!$valid) fail('Username atau password salah.', 401);

        $_SESSION['user_id'] = (int)$u['id'];
        db()->prepare("UPDATE users SET last_login = NOW() WHERE id = ?")->execute([$u['id']]);
        log_activity((int)$u['id'], 'Login', 'Auth', 'User login');

        ok(current_user(), 'Login berhasil');
    }

    if ($a === 'me') {
        $u = current_user();
        if (!$u) fail('Belum login', 401);
        ok($u);
    }

    if ($a === 'logout') {
        $uid = $_SESSION['user_id'] ?? null;
        $_SESSION = [];
        session_destroy();
        log_activity($uid ? (int)$uid : null, 'Logout', 'Auth', 'User logout');
        ok(null, 'Logout berhasil');
    }

    if ($a === 'register') {
        $username = trim($in['username'] ?? '');
        $email = trim($in['email'] ?? '');
        $password = (string)($in['password'] ?? 'Password123!');
        $nama = trim($in['nama_lengkap'] ?? $username);
        if (!$username || !$email || !$nama) fail('Username, email, dan nama wajib diisi.');

        db()->beginTransaction();
        $hash = password_hash($password, PASSWORD_BCRYPT);
        $stmt = db()->prepare("INSERT INTO users (username, email, password_hash, role, is_active) VALUES (?, ?, ?, 'member', 1)");
        $stmt->execute([$username, $email, $hash]);
        $userId = (int)db()->lastInsertId();
        $nomor = 'KRM-' . date('Y') . str_pad((string)$userId, 4, '0', STR_PAD_LEFT);

        $stmt = db()->prepare("INSERT INTO members (user_id, nomor_anggota, nama_lengkap, nik, jenis_kelamin, pekerjaan, alamat, kota, provinsi, no_hp, email, tanggal_bergabung, status_keanggotaan)
                               VALUES (?, ?, ?, ?, 'L', ?, ?, ?, ?, ?, ?, CURDATE(), 'Aktif')");
        $stmt->execute([
            $userId, $nomor, $nama,
            $in['nik'] ?? ('REG' . str_pad((string)$userId, 13, '0', STR_PAD_LEFT)),
            $in['pekerjaan'] ?? null,
            $in['alamat'] ?? '-',
            $in['kota'] ?? '-',
            $in['provinsi'] ?? '-',
            $in['no_hp'] ?? '',
            $email
        ]);
        db()->commit();
        ok(['user_id' => $userId, 'nomor_anggota' => $nomor], 'Registrasi berhasil');
    }

    fail('Action auth tidak dikenal.');
} catch (Throwable $e) {
    if (db()->inTransaction()) db()->rollBack();
    fail('Auth error: ' . $e->getMessage(), 500);
}
