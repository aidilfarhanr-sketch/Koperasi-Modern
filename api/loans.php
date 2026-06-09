<?php
require __DIR__ . '/config.php';

function generate_installments(int $loanId, int $memberId, float $principal, int $tenor, float $monthly): void {
    $pokok = $tenor > 0 ? round($principal / $tenor, 2) : $principal;
    $bunga = max(0, round($monthly - $pokok, 2));
    $sisa = $principal;
    $stmt = db()->prepare("INSERT INTO installments
      (loan_id, member_id, angsuran_ke, tanggal_jatuh_tempo, jumlah_pokok, jumlah_bunga, jumlah_denda, total_bayar, sisa_pokok_setelah, status)
      VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?, 'Belum Bayar')");
    for ($i=1; $i<=$tenor; $i++) {
        $sisa = max(0, $sisa - $pokok);
        $due = date('Y-m-d', strtotime("+$i month"));
        $stmt->execute([$loanId, $memberId, $i, $due, $pokok, $bunga, $monthly, $sisa]);
    }
}

function loan_documents(int $loanId): array {
    $stmt = db()->prepare("SELECT id, member_id, referensi_id, referensi_tabel, jenis_dokumen, nama_file, nama_simpan, path_file, mime_type, ukuran_file, is_verified, verified_at, uploaded_at
                           FROM documents
                           WHERE referensi_tabel='loans' AND referensi_id=?
                           ORDER BY FIELD(jenis_dokumen,'KTP','Slip Gaji','NPWP','Rekening Koran','Surat Keterangan Kerja','Lainnya'), id ASC");
    $stmt->execute([$loanId]);
    $docs = $stmt->fetchAll();
    foreach ($docs as &$d) {
        // path_file seed lama kadang hanya folder; upload baru berisi file lengkap.
        $path = (string)($d['path_file'] ?? '');
        $name = (string)($d['nama_simpan'] ?? '');
        if ($path !== '' && substr($path, -1) === '/' && $name !== '') $path .= $name;
        $d['url'] = $path;
        $abs = $path ? realpath(__DIR__ . '/../' . preg_replace('#^api/#','api/', $path)) : false;
        $d['file_exists'] = $abs && is_file($abs);
    }
    return $docs;
}

function loan_transactions(int $loanId, int $memberId): array {
    $stmt = db()->prepare("SELECT t.*, m.nama_lengkap, m.nomor_anggota
                           FROM transactions t
                           LEFT JOIN members m ON m.id=t.member_id
                           WHERE (t.referensi_tabel='loans' AND t.referensi_id=?)
                              OR (t.member_id=? AND t.kategori IN ('Pencairan Pinjaman','Cicilan Pinjaman','Pelunasan Pinjaman','Denda','Bunga'))
                           ORDER BY t.tanggal DESC, t.id DESC
                           LIMIT 20");
    $stmt->execute([$loanId, $memberId]);
    return $stmt->fetchAll();
}

try {
    $user = require_user();
    $a = action();

    if ($a === 'list') {
        $params = [];
        $where = "WHERE 1=1";
        if (!is_admin($user)) { $where .= " AND l.member_id=?"; $params[] = (int)$user['member_id']; }
        if (!empty($_GET['status'])) { $where .= " AND l.status=?"; $params[] = $_GET['status']; }
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 30)));
        $stmt = db()->prepare("SELECT l.*, m.nama_lengkap, m.nomor_anggota, m.no_hp, m.pekerjaan, m.alamat, m.email,
                                      (SELECT COUNT(*) FROM documents d WHERE d.referensi_tabel='loans' AND d.referensi_id=l.id) AS total_dokumen,
                                      (SELECT COUNT(*) FROM documents d WHERE d.referensi_tabel='loans' AND d.referensi_id=l.id AND d.jenis_dokumen='KTP') AS ktp_count,
                                      (SELECT COUNT(*) FROM documents d WHERE d.referensi_tabel='loans' AND d.referensi_id=l.id AND d.jenis_dokumen IN ('Slip Gaji','Rekening Koran','Surat Keterangan Kerja')) AS slip_count,
                                      (SELECT COUNT(*) FROM transactions t WHERE (t.referensi_tabel='loans' AND t.referensi_id=l.id) OR t.member_id=l.member_id) AS total_transaksi
                               FROM loans l JOIN members m ON m.id=l.member_id
                               $where ORDER BY l.tanggal_pengajuan DESC, l.id DESC LIMIT $limit");
        $stmt->execute($params);
        ok($stmt->fetchAll());
    }

    if ($a === 'detail') {
        $id = (int)($_GET['id'] ?? 0);
        $nomor = trim($_GET['nomor'] ?? '');
        $params = [];
        $where = '';
        if ($id > 0) { $where = 'l.id=?'; $params[] = $id; }
        elseif ($nomor !== '') { $where = 'l.nomor_pinjaman=?'; $params[] = $nomor; }
        else fail('ID pinjaman wajib dikirim.');

        if (!is_admin($user)) { $where .= ' AND l.member_id=?'; $params[] = (int)$user['member_id']; }

        $stmt = db()->prepare("SELECT l.*, m.nama_lengkap, m.nomor_anggota, m.nik, m.no_hp, m.email, m.pekerjaan, m.alamat, m.kota, m.provinsi, m.status_keanggotaan
                               FROM loans l JOIN members m ON m.id=l.member_id
                               WHERE $where LIMIT 1");
        $stmt->execute($params);
        $loan = $stmt->fetch();
        if (!$loan) fail('Pinjaman tidak ditemukan atau tidak punya akses.', 404);
        $loan['documents'] = loan_documents((int)$loan['id']);
        $loan['transactions'] = loan_transactions((int)$loan['id'], (int)$loan['member_id']);
        ok($loan, 'Detail pinjaman berhasil dimuat');
    }

    if ($a === 'ajukan') {
        $in = input();
        $memberId = (int)($user['member_id'] ?? 0);

        if (!$memberId && !empty($in['nomor_anggota'])) {
            $stmt = db()->prepare("SELECT id FROM members WHERE nomor_anggota=? LIMIT 1");
            $stmt->execute([$in['nomor_anggota']]);
            $memberId = (int)$stmt->fetchColumn();
        }
        if (!$memberId) fail('Member tidak ditemukan. Login sebagai anggota atau isi nomor anggota valid.');

        $jumlah = (float)($in['jumlah_diajukan'] ?? $in['jumlah_pinjaman'] ?? 0);
        $tenor = max(1, min(60, (int)($in['tenor'] ?? 12)));
        if ($jumlah < 500000) fail('Minimal pinjaman Rp 500.000.');

        $rate = 1.0;
        $total = $jumlah + ($jumlah * ($rate/100) * $tenor);
        $monthly = ceil($total / $tenor);
        $nomor = next_nomor('PIN');

        db()->beginTransaction();
        $stmt = db()->prepare("INSERT INTO loans
          (member_id, nomor_pinjaman, jumlah_pinjaman, jumlah_diajukan, bunga_rate, tenor, cicilan_per_bulan,
           total_kewajiban, outstanding, tujuan_pinjaman, jaminan, tanggal_pengajuan, status)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), 'Menunggu')");
        $stmt->execute([
            $memberId, $nomor, $jumlah, $jumlah, $rate, $tenor, $monthly,
            $monthly * $tenor, $jumlah,
            $in['tujuan_pinjaman'] ?? 'Lainnya',
            $in['jaminan'] ?? ''
        ]);
        $loanId = (int)db()->lastInsertId();

        // Upload real jika FormData membawa file. Kalau hanya fallback JSON, minimal simpan metadata nama file agar admin tahu dokumen belum real-upload.
        upload_doc($memberId, $loanId, 'loans', 'ktp', 'KTP');
        upload_doc($memberId, $loanId, 'loans', 'slip_gaji', 'Slip Gaji');
        if (!empty($in['upload_fallback']) && !empty($in['ktp_filename'])) {
            $stmt = db()->prepare("INSERT INTO documents (member_id, referensi_id, referensi_tabel, jenis_dokumen, nama_file, nama_simpan, path_file, mime_type, ukuran_file, keterangan)
                                   VALUES (?, ?, 'loans', 'KTP', ?, ?, '', 'metadata/fallback', 0, 'Metadata fallback: file belum tersimpan fisik')");
            $stmt->execute([$memberId, $loanId, $in['ktp_filename'], $in['ktp_filename']]);
        }
        if (!empty($in['upload_fallback']) && !empty($in['slip_filename'])) {
            $stmt = db()->prepare("INSERT INTO documents (member_id, referensi_id, referensi_tabel, jenis_dokumen, nama_file, nama_simpan, path_file, mime_type, ukuran_file, keterangan)
                                   VALUES (?, ?, 'loans', 'Slip Gaji', ?, ?, '', 'metadata/fallback', 0, 'Metadata fallback: file belum tersimpan fisik')");
            $stmt->execute([$memberId, $loanId, $in['slip_filename'], $in['slip_filename']]);
        }

        log_activity((int)$user['user_id'], 'Ajukan', 'Pinjaman', "Pengajuan $nomor sebesar $jumlah");
        db()->commit();
        ok(['id' => $loanId, 'nomor_pinjaman' => $nomor, 'cicilan_per_bulan' => $monthly], 'Pengajuan pinjaman berhasil dikirim');
    }

    if ($a === 'approve') {
        if (!is_admin($user)) fail('Akses admin diperlukan', 403);
        $id = (int)($_GET['id'] ?? 0);
        $stmt = db()->prepare("SELECT * FROM loans WHERE id=?");
        $stmt->execute([$id]);
        $loan = $stmt->fetch();
        if (!$loan) fail('Pinjaman tidak ditemukan', 404);

        db()->beginTransaction();
        db()->prepare("UPDATE loans SET status='Aktif', tanggal_disetujui=CURDATE(), tanggal_pencairan=CURDATE(), reviewed_by=?, reviewed_at=NOW() WHERE id=?")
            ->execute([(int)$user['user_id'], $id]);

        $stmt = db()->prepare("SELECT COUNT(*) FROM installments WHERE loan_id=?");
        $stmt->execute([$id]);
        if ((int)$stmt->fetchColumn() === 0) {
            generate_installments($id, (int)$loan['member_id'], (float)$loan['jumlah_pinjaman'], (int)$loan['tenor'], (float)$loan['cicilan_per_bulan']);
        }
        db()->prepare("INSERT INTO transactions (nomor_transaksi, member_id, jenis, kategori, jumlah, saldo_koperasi, referensi_id, referensi_tabel, keterangan, tanggal, dicatat_oleh)
                       VALUES (?, ?, 'Kredit', 'Pencairan Pinjaman', ?, 0, ?, 'loans', ?, CURDATE(), ?)")
            ->execute(['TRX-' . date('YmdHis') . '-' . rand(100,999), (int)$loan['member_id'], (float)$loan['jumlah_pinjaman'], $id, 'Pencairan/approval pinjaman ' . $loan['nomor_pinjaman'], (int)$user['user_id']]);
        db()->commit();
        log_activity((int)$user['user_id'], 'Approve', 'Pinjaman', "Approve pinjaman #$id");
        ok(['id' => $id], 'Pinjaman disetujui');
    }

    if ($a === 'reject') {
        if (!is_admin($user)) fail('Akses admin diperlukan', 403);
        $id = (int)($_GET['id'] ?? 0);
        $in = input();
        db()->prepare("UPDATE loans SET status='Ditolak', catatan_penolakan=?, reviewed_by=?, reviewed_at=NOW() WHERE id=?")
            ->execute([$in['catatan_penolakan'] ?? $in['alasan'] ?? 'Ditolak admin', (int)$user['user_id'], $id]);
        log_activity((int)$user['user_id'], 'Reject', 'Pinjaman', "Reject pinjaman #$id");
        ok(['id' => $id], 'Pinjaman ditolak');
    }

    fail('Action loans tidak dikenal.');
} catch (Throwable $e) {
    try { if (db()->inTransaction()) db()->rollBack(); } catch (Throwable $ignored) {}
    fail('Loans error: ' . $e->getMessage(), 500);
}
