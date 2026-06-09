-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 29 Bulan Mei 2026 pada 17.08
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `koperasi_raresmaju`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
CREATE TABLE `activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL COMMENT 'Primary key (BIGINT karena volume tinggi)',
  `user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK ke users.id pelaku aksi',
  `aksi` varchar(100) NOT NULL COMMENT 'Nama aksi, contoh: LOGIN, UPDATE_MEMBER, APPROVE_LOAN',
  `modul` varchar(50) NOT NULL COMMENT 'Nama modul, contoh: AUTH, MEMBERS, LOANS, SAVINGS',
  `deskripsi` text DEFAULT NULL COMMENT 'Deskripsi detail aksi yang dilakukan',
  `data_lama` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Data sebelum perubahan (JSON)' CHECK (json_valid(`data_lama`)),
  `data_baru` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Data setelah perubahan (JSON)' CHECK (json_valid(`data_baru`)),
  `referensi_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID entitas yang dipengaruhi',
  `referensi_tabel` varchar(50) DEFAULT NULL COMMENT 'Tabel entitas yang dipengaruhi',
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'IP address pelaku (support IPv6)',
  `user_agent` varchar(500) DEFAULT NULL COMMENT 'Browser / perangkat pelaku',
  `status` enum('Sukses','Gagal','Peringatan') NOT NULL DEFAULT 'Sukses' COMMENT 'Hasil eksekusi aksi',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Audit trail lengkap semua aktivitas pengguna dalam sistem';

--
-- Dumping data untuk tabel `activity_logs`
--

INSERT INTO `activity_logs` (`id`, `user_id`, `aksi`, `modul`, `deskripsi`, `data_lama`, `data_baru`, `referensi_id`, `referensi_tabel`, `ip_address`, `user_agent`, `status`, `created_at`) VALUES
(1, 1, 'LOGIN', 'AUTH', 'Admin berhasil login', NULL, NULL, NULL, NULL, '192.168.1.1', NULL, 'Sukses', '2026-05-29 22:02:36'),
(2, 1, 'APPROVE_LOAN', 'LOANS', 'Admin menyetujui pinjaman PIN-20200301-0001', NULL, NULL, 1, 'loans', '192.168.1.1', NULL, 'Sukses', '2026-05-29 22:02:36'),
(3, 1, 'APPROVE_LOAN', 'LOANS', 'Admin menyetujui pinjaman PIN-20210115-0002', NULL, NULL, 2, 'loans', '192.168.1.1', NULL, 'Sukses', '2026-05-29 22:02:36'),
(4, 3, 'LOGIN', 'AUTH', 'Anggota Budi Santoso login', NULL, NULL, NULL, NULL, '192.168.1.10', NULL, 'Sukses', '2026-05-29 22:02:36'),
(5, 3, 'SUBMIT_LOAN', 'LOANS', 'Anggota mengajukan pinjaman Rp 5.000.000', NULL, NULL, 1, 'loans', '192.168.1.10', NULL, 'Sukses', '2026-05-29 22:02:36'),
(6, 4, 'SUBMIT_LOAN', 'LOANS', 'Anggota mengajukan pinjaman Rp 3.000.000', NULL, NULL, 2, 'loans', '10.0.0.5', NULL, 'Sukses', '2026-05-29 22:02:36'),
(7, 2, 'CREATE_MEMBER', 'MEMBERS', 'Pengurus menambahkan anggota baru Dewi K', NULL, NULL, 4, 'members', '192.168.1.2', NULL, 'Sukses', '2026-05-29 22:02:36'),
(8, 1, 'GENERATE_SHU', 'SHU', 'Admin generate SHU periode 2022', NULL, NULL, NULL, NULL, '192.168.1.1', NULL, 'Sukses', '2026-05-29 22:02:36'),
(9, 6, 'UPDATE_PROFILE', 'MEMBERS', 'Rina mengupdate data profil', NULL, NULL, 6, 'members', '10.0.0.12', NULL, 'Sukses', '2026-05-29 22:02:36'),
(10, 1, 'LOGIN', 'AUTH', 'Admin login gagal — password salah', NULL, NULL, NULL, NULL, '203.0.113.5', NULL, 'Gagal', '2026-05-29 22:02:36'),
(11, 1, 'VERIFY_DOCUMENT', 'DOCUMENTS', 'Admin verifikasi KTP Budi Santoso', NULL, NULL, 1, 'documents', '192.168.1.1', NULL, 'Sukses', '2026-05-29 22:02:36'),
(12, 5, 'LOGIN', 'AUTH', 'Hendra login dari perangkat mobile', NULL, NULL, NULL, NULL, '10.0.0.20', NULL, 'Sukses', '2026-05-29 22:02:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `documents`
--

DROP TABLE IF EXISTS `documents`;
CREATE TABLE `documents` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Primary key',
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK ke members.id pemilik dokumen',
  `referensi_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID terkait (loan_id untuk dokumen pinjaman)',
  `referensi_tabel` varchar(50) DEFAULT NULL COMMENT 'Tabel asal (loans, members, dll)',
  `jenis_dokumen` enum('KTP','Slip Gaji','NPWP','Rekening Koran','Surat Keterangan Kerja','Foto','Akta Kelahiran','Kartu Keluarga','Lainnya') NOT NULL COMMENT 'Tipe dokumen',
  `nama_file` varchar(255) NOT NULL COMMENT 'Nama file asli saat upload',
  `nama_simpan` varchar(255) NOT NULL COMMENT 'Nama file yang disimpan di server (UUID/hash)',
  `path_file` varchar(500) NOT NULL COMMENT 'Path relatif penyimpanan di server',
  `mime_type` varchar(100) NOT NULL COMMENT 'MIME type file, contoh: image/jpeg, application/pdf',
  `ukuran_file` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Ukuran file dalam byte',
  `is_verified` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0=belum diverifikasi, 1=sudah diverifikasi admin',
  `verified_by` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK ke users.id yang memverifikasi',
  `verified_at` datetime DEFAULT NULL,
  `keterangan` varchar(255) DEFAULT NULL,
  `uploaded_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Waktu upload',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Metadata dokumen yang diupload oleh atau untuk anggota';

--
-- Dumping data untuk tabel `documents`
--

INSERT INTO `documents` (`id`, `member_id`, `referensi_id`, `referensi_tabel`, `jenis_dokumen`, `nama_file`, `nama_simpan`, `path_file`, `mime_type`, `ukuran_file`, `is_verified`, `verified_by`, `verified_at`, `keterangan`, `uploaded_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'loans', 'KTP', 'ktp_budi.jpg', 'doc_a1b2c3d4.jpg', 'uploads/docs/2020/03/', 'image/jpeg', 245760, 1, 1, '2020-03-04 00:00:00', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(2, 1, 1, 'loans', 'Slip Gaji', 'slipgaji_budi.pdf', 'doc_e5f6g7h8.pdf', 'uploads/docs/2020/03/', 'application/pdf', 512000, 1, 1, '2020-03-04 00:00:00', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(3, 2, 2, 'loans', 'KTP', 'ktp_siti.jpg', 'doc_i9j0k1l2.jpg', 'uploads/docs/2021/01/', 'image/jpeg', 198000, 1, 1, '2021-01-19 00:00:00', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(4, 2, 2, 'loans', 'Surat Keterangan Kerja', 'sk_kerja_siti.pdf', 'doc_m3n4o5p6.pdf', 'uploads/docs/2021/01/', 'application/pdf', 380000, 1, 1, '2021-01-19 00:00:00', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(5, 3, 3, 'loans', 'KTP', 'ktp_agus.jpg', 'doc_q7r8s9t0.jpg', 'uploads/docs/2022/05/', 'image/jpeg', 310000, 1, 1, '2022-05-09 00:00:00', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(6, 3, 3, 'loans', 'NPWP', 'npwp_agus.jpg', 'doc_u1v2w3x4.jpg', 'uploads/docs/2022/05/', 'image/jpeg', 220000, 1, 1, '2022-05-09 00:00:00', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(7, 4, 4, 'loans', 'KTP', 'ktp_dewi.jpg', 'doc_y5z6a7b8.jpg', 'uploads/docs/2023/06/', 'image/jpeg', 265000, 0, NULL, NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(8, 4, 4, 'loans', 'Slip Gaji', 'slip_dewi.pdf', 'doc_c9d0e1f2.pdf', 'uploads/docs/2023/06/', 'application/pdf', 430000, 0, NULL, NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(9, 5, NULL, 'members', 'Foto', 'foto_hendra.jpg', 'doc_g3h4i5j6.jpg', 'uploads/profile/', 'image/jpeg', 185000, 1, 1, '2021-03-04 00:00:00', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(10, 7, 7, 'loans', 'KTP', 'ktp_joko.jpg', 'doc_k7l8m9n0.jpg', 'uploads/docs/2024/09/', 'image/jpeg', 198000, 0, NULL, NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36', '2026-05-29 22:02:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `installments`
--

DROP TABLE IF EXISTS `installments`;
CREATE TABLE `installments` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Primary key',
  `loan_id` int(10) UNSIGNED NOT NULL COMMENT 'FK ke loans.id',
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK ke members.id (denormalisasi untuk query cepat)',
  `angsuran_ke` tinyint(3) UNSIGNED NOT NULL COMMENT 'Urutan cicilan (1, 2, 3, ...)',
  `tanggal_jatuh_tempo` date NOT NULL COMMENT 'Tanggal wajib bayar cicilan ini',
  `tanggal_bayar` date DEFAULT NULL COMMENT 'Tanggal realisasi pembayaran',
  `jumlah_pokok` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Komponen pokok dalam cicilan ini',
  `jumlah_bunga` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Komponen bunga dalam cicilan ini',
  `jumlah_denda` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Denda keterlambatan jika ada',
  `total_bayar` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Total yang dibayar (pokok+bunga+denda)',
  `sisa_pokok_setelah` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Sisa outstanding setelah cicilan ini',
  `status` enum('Belum Bayar','Lunas','Terlambat','Sebagian','Waived') NOT NULL DEFAULT 'Belum Bayar' COMMENT 'Status pembayaran cicilan',
  `metode_bayar` enum('Tunai','Transfer','Potong Simpanan','Lainnya') DEFAULT NULL COMMENT 'Cara pembayaran',
  `referensi_bayar` varchar(50) DEFAULT NULL COMMENT 'Nomor bukti bayar / referensi transfer',
  `keterangan` varchar(255) DEFAULT NULL,
  `dibayar_ke` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK ke users.id yang menerima/mencatat pembayaran',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Jadwal dan riwayat pembayaran cicilan pinjaman';

--
-- Dumping data untuk tabel `installments`
--

INSERT INTO `installments` (`id`, `loan_id`, `member_id`, `angsuran_ke`, `tanggal_jatuh_tempo`, `tanggal_bayar`, `jumlah_pokok`, `jumlah_bunga`, `jumlah_denda`, `total_bayar`, `sisa_pokok_setelah`, `status`, `metode_bayar`, `referensi_bayar`, `keterangan`, `dibayar_ke`, `created_at`, `updated_at`) VALUES
(1, 3, 3, 1, '2022-06-12', '2022-06-10', 347917.00, 150000.00, 0.00, 497917.00, 9652083.00, 'Lunas', 'Transfer', 'TRF-2206001', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(2, 3, 3, 2, '2022-07-12', '2022-07-11', 353130.00, 144787.00, 0.00, 497917.00, 9298953.00, 'Lunas', 'Transfer', 'TRF-2207002', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(3, 3, 3, 3, '2022-08-12', '2022-08-15', 358350.00, 139567.00, 4979.17, 502896.17, 8940603.00, 'Lunas', 'Tunai', 'KWT-2208003', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(4, 3, 3, 4, '2022-09-12', '2022-09-10', 363625.00, 134280.00, 0.00, 497905.00, 8576978.00, 'Lunas', 'Transfer', 'TRF-2209004', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(5, 3, 3, 5, '2022-10-12', '2022-10-12', 368979.00, 128938.00, 0.00, 497917.00, 8207999.00, 'Lunas', 'Transfer', 'TRF-2210005', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(6, 3, 3, 6, '2022-11-12', '2022-11-11', 374414.00, 123503.00, 0.00, 497917.00, 7833585.00, 'Lunas', 'Transfer', 'TRF-2211006', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(7, 3, 3, 7, '2022-12-12', '2022-12-12', 379930.00, 117987.00, 0.00, 497917.00, 7453655.00, 'Lunas', 'Tunai', 'KWT-2212007', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(8, 3, 3, 8, '2023-01-12', '2023-01-12', 385529.00, 112388.00, 0.00, 497917.00, 7068126.00, 'Lunas', 'Transfer', 'TRF-2301008', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(9, 3, 3, 9, '2023-02-12', '2023-02-14', 391212.00, 106702.00, 4979.17, 502893.17, 6676914.00, 'Lunas', 'Transfer', 'TRF-2302009', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(10, 3, 3, 10, '2023-03-12', '2023-03-12', 396980.00, 100937.00, 0.00, 497917.00, 6279934.00, 'Lunas', 'Transfer', 'TRF-2303010', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(11, 3, 3, 11, '2023-04-12', '2023-04-11', 402835.00, 95082.00, 0.00, 497917.00, 5877099.00, 'Lunas', 'Transfer', 'TRF-2304011', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(12, 3, 3, 12, '2023-05-12', '2023-05-12', 408778.00, 89139.00, 0.00, 497917.00, 5468321.00, 'Lunas', 'Tunai', 'KWT-2305012', NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(13, 3, 3, 13, '2023-06-12', NULL, 414810.00, 82025.00, 0.00, 496835.00, 5053511.00, 'Belum Bayar', NULL, NULL, NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(14, 3, 3, 14, '2023-07-12', NULL, 420931.00, 75877.00, 0.00, 496808.00, 4632580.00, 'Belum Bayar', NULL, NULL, NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(15, 3, 3, 15, '2023-08-12', NULL, 427145.00, 69576.00, 0.00, 496721.00, 4205435.00, 'Belum Bayar', NULL, NULL, NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `loans`
--

DROP TABLE IF EXISTS `loans`;
CREATE TABLE `loans` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Primary key',
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK ke members.id',
  `nomor_pinjaman` varchar(30) NOT NULL COMMENT 'Nomor pinjaman unik, format: PIN-YYYYMMDD-XXXX',
  `jumlah_pinjaman` decimal(15,2) NOT NULL COMMENT 'Pokok pinjaman disetujui',
  `jumlah_diajukan` decimal(15,2) NOT NULL COMMENT 'Nominal yang diajukan anggota',
  `bunga_rate` decimal(5,2) NOT NULL DEFAULT 1.50 COMMENT 'Suku bunga per bulan (%)',
  `tenor` tinyint(3) UNSIGNED NOT NULL COMMENT 'Jangka waktu dalam bulan',
  `cicilan_per_bulan` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Nominal cicilan bulanan',
  `total_kewajiban` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Total pokok + bunga selama tenor',
  `outstanding` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Sisa kewajiban yang belum terbayar',
  `tujuan_pinjaman` varchar(255) DEFAULT NULL COMMENT 'Keperluan penggunaan pinjaman',
  `jaminan` varchar(255) DEFAULT NULL COMMENT 'Keterangan jaminan/agunan',
  `tanggal_pengajuan` date NOT NULL COMMENT 'Tanggal anggota mengajukan',
  `tanggal_disetujui` date DEFAULT NULL COMMENT 'Tanggal admin menyetujui',
  `tanggal_pencairan` date DEFAULT NULL COMMENT 'Tanggal dana dicairkan',
  `tanggal_jatuh_tempo` date DEFAULT NULL COMMENT 'Tanggal pelunasan terakhir',
  `tanggal_lunas` date DEFAULT NULL COMMENT 'Tanggal realisasi pelunasan',
  `status` enum('Menunggu','Proses','Disetujui','Dicairkan','Aktif','Lunas','Ditolak','Macet') NOT NULL DEFAULT 'Menunggu' COMMENT 'Status alur pinjaman',
  `catatan_admin` text DEFAULT NULL COMMENT 'Catatan internal admin',
  `catatan_penolakan` text DEFAULT NULL COMMENT 'Alasan penolakan jika ditolak',
  `reviewed_by` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK ke users.id yang review',
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Header pengajuan dan record pinjaman aktif anggota';

--
-- Dumping data untuk tabel `loans`
--

INSERT INTO `loans` (`id`, `member_id`, `nomor_pinjaman`, `jumlah_pinjaman`, `jumlah_diajukan`, `bunga_rate`, `tenor`, `cicilan_per_bulan`, `total_kewajiban`, `outstanding`, `tujuan_pinjaman`, `jaminan`, `tanggal_pengajuan`, `tanggal_disetujui`, `tanggal_pencairan`, `tanggal_jatuh_tempo`, `tanggal_lunas`, `status`, `catatan_admin`, `catatan_penolakan`, `reviewed_by`, `reviewed_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'PIN-20200301-0001', 5000000.00, 5000000.00, 1.50, 12, 456250.00, 5475000.00, 0.00, 'Modal usaha kecil', NULL, '2020-03-01', '2020-03-05', '2020-03-07', '2021-03-07', NULL, 'Lunas', NULL, NULL, 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(2, 2, 'PIN-20210115-0002', 3000000.00, 3000000.00, 1.50, 6, 532500.00, 3195000.00, 0.00, 'Renovasi rumah', NULL, '2021-01-15', '2021-01-20', '2021-01-22', '2021-07-22', NULL, 'Lunas', NULL, NULL, 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(3, 3, 'PIN-20220501-0003', 10000000.00, 10000000.00, 1.50, 24, 497917.00, 11950000.00, 5975000.00, 'Pengembangan usaha', NULL, '2022-05-01', '2022-05-10', '2022-05-12', '2024-05-12', NULL, 'Aktif', NULL, NULL, 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(4, 4, 'PIN-20230601-0004', 7000000.00, 8000000.00, 1.50, 18, 447222.00, 8050000.00, 3576000.00, 'Pendidikan anak', NULL, '2023-06-01', '2023-06-08', '2023-06-10', '2024-12-10', NULL, 'Aktif', NULL, NULL, 2, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(5, 5, 'PIN-20240101-0005', 20000000.00, 20000000.00, 1.50, 36, 666667.00, 24000000.00, 20000000.00, 'Beli kendaraan operasional', NULL, '2024-01-01', '2024-01-05', '2024-01-08', '2027-01-08', NULL, 'Aktif', NULL, NULL, 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(6, 6, 'PIN-20240801-0006', 5000000.00, 5000000.00, 1.50, 12, 456250.00, 5475000.00, 5475000.00, 'Kebutuhan rumah tangga', NULL, '2024-08-01', NULL, NULL, NULL, NULL, 'Menunggu', NULL, NULL, NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(7, 7, 'PIN-20240901-0007', 2000000.00, 2000000.00, 1.50, 6, 365000.00, 2190000.00, 2190000.00, 'Modal pertanian', NULL, '2024-09-01', '2024-09-03', NULL, '2025-03-03', NULL, 'Proses', NULL, NULL, 2, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `members`
--

DROP TABLE IF EXISTS `members`;
CREATE TABLE `members` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Primary key',
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'FK ke users.id',
  `nomor_anggota` varchar(20) NOT NULL COMMENT 'Nomor anggota unik, format: KRM-YYYYXXXX',
  `nama_lengkap` varchar(150) NOT NULL COMMENT 'Nama lengkap sesuai KTP',
  `nik` varchar(16) NOT NULL COMMENT 'NIK KTP 16 digit',
  `tempat_lahir` varchar(100) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `jenis_kelamin` enum('L','P') DEFAULT NULL COMMENT 'L=Laki-laki, P=Perempuan',
  `agama` varchar(30) DEFAULT NULL,
  `status_pernikahan` enum('Belum Menikah','Menikah','Cerai Hidup','Cerai Mati') DEFAULT NULL,
  `pendidikan` varchar(50) DEFAULT NULL,
  `pekerjaan` varchar(100) DEFAULT NULL COMMENT 'Pekerjaan / profesi',
  `nama_perusahaan` varchar(150) DEFAULT NULL,
  `penghasilan_bulanan` decimal(15,2) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `kelurahan` varchar(100) DEFAULT NULL,
  `kecamatan` varchar(100) DEFAULT NULL,
  `kota` varchar(100) DEFAULT NULL,
  `provinsi` varchar(100) DEFAULT NULL,
  `kode_pos` varchar(10) DEFAULT NULL,
  `no_telepon` varchar(20) DEFAULT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `foto_profil` varchar(255) DEFAULT NULL COMMENT 'Path file foto profil',
  `tanggal_bergabung` date NOT NULL COMMENT 'Tanggal resmi menjadi anggota',
  `status_keanggotaan` enum('Aktif','Tidak Aktif','Keluar','Meninggal') NOT NULL DEFAULT 'Aktif' COMMENT 'Status keanggotaan saat ini',
  `simpanan_pokok_lunas` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=sudah lunas simpanan pokok',
  `keterangan` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Profil lengkap setiap anggota koperasi';

--
-- Dumping data untuk tabel `members`
--

INSERT INTO `members` (`id`, `user_id`, `nomor_anggota`, `nama_lengkap`, `nik`, `tempat_lahir`, `tanggal_lahir`, `jenis_kelamin`, `agama`, `status_pernikahan`, `pendidikan`, `pekerjaan`, `nama_perusahaan`, `penghasilan_bulanan`, `alamat`, `kelurahan`, `kecamatan`, `kota`, `provinsi`, `kode_pos`, `no_telepon`, `no_hp`, `email`, `foto_profil`, `tanggal_bergabung`, `status_keanggotaan`, `simpanan_pokok_lunas`, `keterangan`, `created_at`, `updated_at`) VALUES
(1, 3, 'KRM-20200001', 'Budi Santoso', '3201011234560001', 'Bandung', '1985-03-12', 'L', NULL, NULL, NULL, 'PNS', 'Pemerintah Kota', 6500000.00, 'Jl. Mawar No. 5', NULL, NULL, 'Bandung', 'Jawa Barat', NULL, NULL, '081234567801', NULL, NULL, '2020-01-15', 'Aktif', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(2, 4, 'KRM-20200002', 'Siti Rahayu', '3201021234560002', 'Jakarta', '1990-07-22', 'P', NULL, NULL, NULL, 'Guru', 'SMA Negeri 1', 4500000.00, 'Jl. Melati No. 12', NULL, NULL, 'Jakarta', 'DKI Jakarta', NULL, NULL, '081234567802', NULL, NULL, '2020-02-01', 'Aktif', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(3, 5, 'KRM-20200003', 'Agus Wibowo', '3201031234560003', 'Yogyakarta', '1988-11-05', 'L', NULL, NULL, NULL, 'Wiraswasta', 'Toko Elektronik Agus', 8000000.00, 'Jl. Anggrek No. 8', NULL, NULL, 'Yogyakarta', 'DIY', NULL, NULL, '081234567803', NULL, NULL, '2020-03-10', 'Aktif', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(4, 6, 'KRM-20210004', 'Dewi Kurniawati', '3201041234560004', 'Surabaya', '1992-05-18', 'P', NULL, NULL, NULL, 'Karyawan Swasta', 'PT. Maju Bersama', 5500000.00, 'Jl. Kenanga No. 3', NULL, NULL, 'Surabaya', 'Jawa Timur', NULL, NULL, '081234567804', NULL, NULL, '2021-01-20', 'Aktif', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(5, 7, 'KRM-20210005', 'Hendra Pratama', '3201051234560005', 'Medan', '1983-09-30', 'L', NULL, NULL, NULL, 'Dokter', 'RS Harapan Sehat', 15000000.00, 'Jl. Dahlia No. 21', NULL, NULL, 'Medan', 'Sumatera Utara', NULL, NULL, '081234567805', NULL, NULL, '2021-03-05', 'Aktif', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(6, 8, 'KRM-20210006', 'Rina Maharani', '3201061234560006', 'Semarang', '1995-01-14', 'P', NULL, NULL, NULL, 'Akuntan', 'KAP Jaya Mandiri', 7500000.00, 'Jl. Flamboyan No. 7', NULL, NULL, 'Semarang', 'Jawa Tengah', NULL, NULL, '081234567806', NULL, NULL, '2021-06-15', 'Aktif', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(7, 9, 'KRM-20220007', 'Joko Susilo', '3201071234560007', 'Malang', '1980-12-25', 'L', NULL, NULL, NULL, 'Petani', 'Usaha Mandiri', 3500000.00, 'Dusun Sumber No. 2', NULL, NULL, 'Malang', 'Jawa Timur', NULL, NULL, '081234567807', NULL, NULL, '2022-01-10', 'Aktif', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(8, 10, 'KRM-20220008', 'Fitri Nurmala', '3201081234560008', 'Makassar', '1998-04-08', 'P', NULL, NULL, NULL, 'Mahasiswa', NULL, 1000000.00, 'Jl. Cempaka No. 15', NULL, NULL, 'Makassar', 'Sulawesi Selatan', NULL, NULL, '081234567808', NULL, NULL, '2022-04-01', 'Tidak Aktif', 0, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Primary key',
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'FK ke users.id penerima notifikasi',
  `judul` varchar(150) NOT NULL COMMENT 'Judul notifikasi',
  `pesan` text NOT NULL COMMENT 'Isi pesan notifikasi',
  `tipe` enum('Info','Sukses','Peringatan','Error','Pinjaman','Simpanan','Cicilan','SHU','Keanggotaan','Sistem') NOT NULL DEFAULT 'Info' COMMENT 'Tipe/kategori notifikasi',
  `is_read` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0=belum dibaca, 1=sudah dibaca',
  `read_at` datetime DEFAULT NULL COMMENT 'Waktu dibaca',
  `action_url` varchar(255) DEFAULT NULL COMMENT 'URL / hash navigasi saat diklik',
  `referensi_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID entitas terkait (loan_id, saving_id, dll)',
  `referensi_tabel` varchar(50) DEFAULT NULL COMMENT 'Nama tabel entitas terkait',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Notifikasi in-app untuk semua pengguna';

--
-- Dumping data untuk tabel `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `judul`, `pesan`, `tipe`, `is_read`, `read_at`, `action_url`, `referensi_id`, `referensi_tabel`, `created_at`, `updated_at`) VALUES
(1, 3, 'Pinjaman Disetujui ✅', 'Selamat! Pengajuan pinjaman Anda sebesar Rp 5.000.000 telah disetujui. Dana akan dicairkan dalam 1x24 jam.', 'Pinjaman', 1, NULL, '#loans', 1, 'loans', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(2, 4, 'Pinjaman Disetujui ✅', 'Selamat! Pengajuan pinjaman Anda sebesar Rp 7.000.000 telah disetujui.', 'Pinjaman', 0, NULL, '#loans', 4, 'loans', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(3, 8, 'Cicilan Jatuh Tempo ⏰', 'Cicilan pinjaman Anda angsuran ke-13 jatuh tempo tanggal 12 bulan ini. Segera lakukan pembayaran.', 'Cicilan', 0, NULL, '#installments', 13, 'installments', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(4, 1, 'Pengajuan Pinjaman Baru 🔔', 'Ada pengajuan pinjaman baru dari Rina Maharani sebesar Rp 5.000.000 menunggu review Anda.', 'Pinjaman', 0, NULL, '#admin-loans', 6, 'loans', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(5, 5, 'SHU Tahun 2022 Tersedia 🎉', 'SHU Anda untuk periode tahun 2022 sebesar Rp 1.643.000 telah siap dibagikan.', 'SHU', 1, NULL, '#shu', 5, 'shu_distributions', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(6, 6, 'Simpanan Berhasil 💰', 'Simpanan pokok Anda sebesar Rp 500.000 berhasil dicatat. Terima kasih.', 'Simpanan', 1, NULL, '#savings', 19, 'savings', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(7, 1, 'Anggota Tidak Aktif ⚠️', 'Anggota Fitri Nurmala (KRM-20220008) belum melakukan transaksi selama 3 bulan.', 'Peringatan', 0, NULL, '#admin-members', 8, 'members', '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(8, 2, 'Login Berhasil', 'Anda berhasil login ke sistem Koperasi RaresMaju dari perangkat baru.', 'Info', 1, NULL, NULL, NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `savings`
--

DROP TABLE IF EXISTS `savings`;
CREATE TABLE `savings` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Primary key',
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK ke members.id',
  `jenis_simpanan` enum('Pokok','Wajib','Sukarela','Berjangka','Hari Raya') NOT NULL COMMENT 'Kategori simpanan',
  `jumlah` decimal(15,2) NOT NULL COMMENT 'Nominal transaksi (positif=setor, negatif=tarik)',
  `saldo_setelah` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Saldo akumulatif setelah transaksi ini',
  `keterangan` varchar(255) DEFAULT NULL COMMENT 'Catatan tambahan transaksi',
  `referensi_no` varchar(50) DEFAULT NULL COMMENT 'Nomor referensi / bukti setor',
  `tanggal_transaksi` date NOT NULL COMMENT 'Tanggal efektif transaksi',
  `jatuh_tempo` date DEFAULT NULL COMMENT 'Untuk simpanan berjangka',
  `bunga_rate` decimal(5,2) DEFAULT 0.00 COMMENT 'Tingkat bunga per tahun (%)',
  `status` enum('Pending','Berhasil','Gagal','Dibatalkan') NOT NULL DEFAULT 'Berhasil' COMMENT 'Status transaksi',
  `approved_by` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK ke users.id yang menyetujui',
  `approved_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Riwayat transaksi simpanan anggota (semua jenis)';

--
-- Dumping data untuk tabel `savings`
--

INSERT INTO `savings` (`id`, `member_id`, `jenis_simpanan`, `jumlah`, `saldo_setelah`, `keterangan`, `referensi_no`, `tanggal_transaksi`, `jatuh_tempo`, `bunga_rate`, `status`, `approved_by`, `approved_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'Pokok', 500000.00, 500000.00, 'Simpanan pokok awal keanggotaan', NULL, '2020-01-15', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(2, 1, 'Wajib', 100000.00, 100000.00, 'Simpanan wajib Januari 2020', NULL, '2020-01-31', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(3, 1, 'Wajib', 100000.00, 200000.00, 'Simpanan wajib Februari 2020', NULL, '2020-02-28', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(4, 1, 'Sukarela', 500000.00, 500000.00, 'Tabungan sukarela', NULL, '2020-03-10', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(5, 1, 'Wajib', 100000.00, 300000.00, 'Simpanan wajib Maret 2020', NULL, '2020-03-31', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(6, 2, 'Pokok', 500000.00, 500000.00, 'Simpanan pokok awal keanggotaan', NULL, '2020-02-01', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(7, 2, 'Wajib', 100000.00, 100000.00, 'Simpanan wajib Februari 2020', NULL, '2020-02-29', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(8, 2, 'Wajib', 100000.00, 200000.00, 'Simpanan wajib Maret 2020', NULL, '2020-03-31', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(9, 2, 'Sukarela', 1000000.00, 1000000.00, 'Tabungan hari raya', NULL, '2020-04-01', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(10, 3, 'Pokok', 500000.00, 500000.00, 'Simpanan pokok awal keanggotaan', NULL, '2020-03-10', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(11, 3, 'Wajib', 100000.00, 100000.00, 'Simpanan wajib Maret 2020', NULL, '2020-03-31', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(12, 3, 'Sukarela', 2000000.00, 2000000.00, 'Tabungan sukarela besar', NULL, '2020-05-01', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(13, 4, 'Pokok', 500000.00, 500000.00, 'Simpanan pokok awal keanggotaan', NULL, '2021-01-20', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(14, 4, 'Wajib', 100000.00, 100000.00, 'Simpanan wajib Januari 2021', NULL, '2021-01-31', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(15, 4, 'Wajib', 100000.00, 200000.00, 'Simpanan wajib Februari 2021', NULL, '2021-02-28', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(16, 5, 'Pokok', 500000.00, 500000.00, 'Simpanan pokok awal keanggotaan', NULL, '2021-03-05', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(17, 5, 'Wajib', 100000.00, 100000.00, 'Simpanan wajib Maret 2021', NULL, '2021-03-31', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(18, 5, 'Berjangka', 10000000.00, 10000000.00, 'Deposito 12 bulan 6% pa', NULL, '2021-04-01', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(19, 6, 'Pokok', 500000.00, 500000.00, 'Simpanan pokok awal keanggotaan', NULL, '2021-06-15', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(20, 6, 'Wajib', 100000.00, 100000.00, 'Simpanan wajib Juni 2021', NULL, '2021-06-30', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(21, 7, 'Pokok', 500000.00, 500000.00, 'Simpanan pokok awal keanggotaan', NULL, '2022-01-10', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(22, 7, 'Wajib', 100000.00, 100000.00, 'Simpanan wajib Januari 2022', NULL, '2022-01-31', NULL, 0.00, 'Berhasil', 1, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `shu_distributions`
--

DROP TABLE IF EXISTS `shu_distributions`;
CREATE TABLE `shu_distributions` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Primary key',
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK ke members.id',
  `periode_tahun` year(4) NOT NULL COMMENT 'Tahun buku SHU',
  `total_shu_koperasi` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Total SHU koperasi pada periode ini',
  `porsi_simpanan` decimal(5,2) NOT NULL DEFAULT 40.00 COMMENT 'Persentase porsi berdasarkan simpanan (%)',
  `porsi_pinjaman` decimal(5,2) NOT NULL DEFAULT 40.00 COMMENT 'Persentase porsi berdasarkan pinjaman (%)',
  `porsi_lain` decimal(5,2) NOT NULL DEFAULT 20.00 COMMENT 'Porsi lain-lain (%)',
  `total_simpanan_member` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Akumulasi simpanan anggota di periode ini',
  `total_pinjaman_member` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Akumulasi pinjaman anggota di periode ini',
  `shu_simpanan` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Bagian SHU dari komponen simpanan',
  `shu_pinjaman` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Bagian SHU dari komponen pinjaman',
  `shu_lain` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Bagian SHU komponen lain',
  `total_shu` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Total SHU diterima anggota',
  `status` enum('Draft','Final','Dibayar','Ditahan') NOT NULL DEFAULT 'Draft' COMMENT 'Status distribusi SHU',
  `tanggal_distribusi` date DEFAULT NULL COMMENT 'Tanggal SHU dibagikan',
  `keterangan` text DEFAULT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK ke users.id yang membuat record',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sisa Hasil Usaha (SHU) per anggota per periode tahun buku';

--
-- Dumping data untuk tabel `shu_distributions`
--

INSERT INTO `shu_distributions` (`id`, `member_id`, `periode_tahun`, `total_shu_koperasi`, `porsi_simpanan`, `porsi_pinjaman`, `porsi_lain`, `total_simpanan_member`, `total_pinjaman_member`, `shu_simpanan`, `shu_pinjaman`, `shu_lain`, `total_shu`, `status`, `tanggal_distribusi`, `keterangan`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 1, '2022', 50000000.00, 40.00, 40.00, 20.00, 3600000.00, 5000000.00, 450000.00, 312500.00, 90000.00, 852500.00, 'Dibayar', '2023-01-31', NULL, 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(2, 2, '2022', 50000000.00, 40.00, 40.00, 20.00, 1800000.00, 3000000.00, 225000.00, 187500.00, 54000.00, 466500.00, 'Dibayar', '2023-01-31', NULL, 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(3, 3, '2022', 50000000.00, 40.00, 40.00, 20.00, 2600000.00, 10000000.00, 325000.00, 625000.00, 150000.00, 1100000.00, 'Dibayar', '2023-01-31', NULL, 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(4, 4, '2022', 50000000.00, 40.00, 40.00, 20.00, 700000.00, 0.00, 87500.00, 0.00, 21000.00, 108500.00, 'Dibayar', '2023-01-31', NULL, 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(5, 5, '2022', 50000000.00, 40.00, 40.00, 20.00, 10600000.00, 0.00, 1325000.00, 0.00, 318000.00, 1643000.00, 'Dibayar', '2023-01-31', NULL, 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(6, 1, '2023', 65000000.00, 40.00, 40.00, 20.00, 4200000.00, 5975000.00, 546000.00, 464625.00, 130000.00, 1140625.00, 'Final', NULL, NULL, 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(7, 2, '2023', 65000000.00, 40.00, 40.00, 20.00, 2100000.00, 3576000.00, 273000.00, 278028.00, 65000.00, 616028.00, 'Final', NULL, NULL, 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(8, 3, '2023', 65000000.00, 40.00, 40.00, 20.00, 3000000.00, 7000000.00, 390000.00, 544400.00, 100000.00, 1034400.00, 'Final', NULL, NULL, 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `transactions`
--

DROP TABLE IF EXISTS `transactions`;
CREATE TABLE `transactions` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Primary key',
  `nomor_transaksi` varchar(30) NOT NULL COMMENT 'Nomor unik transaksi, format: TRX-YYYYMMDD-XXXX',
  `member_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK ke members.id (NULL jika transaksi internal)',
  `jenis` enum('Debit','Kredit') NOT NULL COMMENT 'Debit=dana masuk ke koperasi, Kredit=keluar',
  `kategori` enum('Simpanan Pokok','Simpanan Wajib','Simpanan Sukarela','Simpanan Berjangka','Penarikan Simpanan','Pencairan Pinjaman','Cicilan Pinjaman','Pelunasan Pinjaman','Denda','Bunga','SHU','Biaya Administrasi','Pendapatan Lain','Biaya Operasional','Lainnya') NOT NULL COMMENT 'Klasifikasi transaksi untuk laporan keuangan',
  `jumlah` decimal(15,2) NOT NULL COMMENT 'Nominal transaksi (selalu positif)',
  `saldo_koperasi` decimal(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Saldo kas koperasi setelah transaksi',
  `referensi_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID FK ke tabel asal (savings/loans/installments)',
  `referensi_tabel` varchar(50) DEFAULT NULL COMMENT 'Nama tabel asal referensi',
  `keterangan` varchar(500) DEFAULT NULL COMMENT 'Deskripsi detail transaksi',
  `tanggal` date NOT NULL COMMENT 'Tanggal efektif transaksi',
  `dicatat_oleh` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK ke users.id yang mencatat',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Ledger / jurnal kas umum seluruh transaksi keuangan koperasi';

--
-- Dumping data untuk tabel `transactions`
--

INSERT INTO `transactions` (`id`, `nomor_transaksi`, `member_id`, `jenis`, `kategori`, `jumlah`, `saldo_koperasi`, `referensi_id`, `referensi_tabel`, `keterangan`, `tanggal`, `dicatat_oleh`, `created_at`, `updated_at`) VALUES
(1, 'TRX-20200115-0001', 1, 'Debit', 'Simpanan Pokok', 500000.00, 500000.00, 1, 'savings', 'Simpanan pokok Budi Santoso', '2020-01-15', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(2, 'TRX-20200131-0002', 1, 'Debit', 'Simpanan Wajib', 100000.00, 600000.00, 2, 'savings', 'Simpanan wajib Jan 2020 Budi', '2020-01-31', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(3, 'TRX-20200201-0003', 2, 'Debit', 'Simpanan Pokok', 500000.00, 1100000.00, 6, 'savings', 'Simpanan pokok Siti Rahayu', '2020-02-01', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(4, 'TRX-20200307-0004', 1, 'Kredit', 'Pencairan Pinjaman', 5000000.00, -3900000.00, 1, 'loans', 'Pencairan pinjaman PIN-20200301-0001', '2020-03-07', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(5, 'TRX-20210122-0005', 2, 'Kredit', 'Pencairan Pinjaman', 3000000.00, -2900000.00, 2, 'loans', 'Pencairan pinjaman PIN-20210115-0002', '2021-01-22', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(6, 'TRX-20220512-0006', 3, 'Kredit', 'Pencairan Pinjaman', 10000000.00, -12900000.00, 3, 'loans', 'Pencairan pinjaman PIN-20220501-0003', '2022-05-12', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(7, 'TRX-20220610-0007', 3, 'Debit', 'Cicilan Pinjaman', 497917.00, -12402083.00, 1, 'installments', 'Cicilan ke-1 Agus Wibowo', '2022-06-10', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(8, 'TRX-20220711-0008', 3, 'Debit', 'Cicilan Pinjaman', 497917.00, -11904166.00, 2, 'installments', 'Cicilan ke-2 Agus Wibowo', '2022-07-11', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(9, 'TRX-20240101-0009', 5, 'Kredit', 'Pencairan Pinjaman', 20000000.00, -31904166.00, 5, 'loans', 'Pencairan pinjaman PIN-20240101-0005', '2024-01-08', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(10, 'TRX-20240131-0010', NULL, 'Debit', 'Pendapatan Lain', 750000.00, -31154166.00, NULL, NULL, 'Pendapatan jasa layanan koperasi', '2024-01-31', 1, '2026-05-29 22:02:36', '2026-05-29 22:02:36');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Primary key',
  `username` varchar(50) NOT NULL COMMENT 'Username unik untuk login',
  `email` varchar(100) NOT NULL COMMENT 'Alamat email aktif',
  `password_hash` varchar(255) NOT NULL COMMENT 'Bcrypt hash password',
  `role` enum('admin','member','pengurus') NOT NULL DEFAULT 'member' COMMENT 'Hak akses: admin=full, pengurus=manajemen, member=anggota',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1=aktif, 0=dinonaktifkan',
  `last_login` datetime DEFAULT NULL COMMENT 'Waktu login terakhir',
  `remember_token` varchar(100) DEFAULT NULL COMMENT 'Token remember me',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabel autentikasi semua pengguna sistem';

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `role`, `is_active`, `last_login`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'admin@raresmaju.id', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'admin', 1, '2026-05-29 22:02:36', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(2, 'pengurus1', 'pengurus1@raresmaju.id', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'pengurus', 1, '2026-05-29 22:02:36', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(3, 'budi_s', 'budi.santoso@email.com', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'member', 1, '2026-05-29 22:02:36', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(4, 'siti_r', 'siti.rahayu@email.com', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'member', 1, '2026-05-29 22:02:36', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(5, 'agus_w', 'agus.wibowo@email.com', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'member', 1, '2026-05-29 22:02:36', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(6, 'dewi_k', 'dewi.kurnia@email.com', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'member', 1, '2026-05-29 22:02:36', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(7, 'hendra_p', 'hendra.pratama@email.com', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'member', 1, '2026-05-29 22:02:36', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(8, 'rina_m', 'rina.maharani@email.com', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'member', 1, '2026-05-29 22:02:36', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(9, 'joko_s', 'joko.susilo@email.com', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'member', 1, '2026-05-29 22:02:36', NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36'),
(10, 'fitri_n', 'fitri.nurmala@email.com', '$2y$12$A749BZuOF.5YimqShD/Y3el4lYuW8247OU8wFTA9Gz4fvAna2Axra', 'member', 0, NULL, NULL, '2026-05-29 22:02:36', '2026-05-29 22:02:36');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_logs_user` (`user_id`),
  ADD KEY `idx_logs_aksi` (`aksi`),
  ADD KEY `idx_logs_modul` (`modul`),
  ADD KEY `idx_logs_created` (`created_at`),
  ADD KEY `idx_logs_referensi` (`referensi_tabel`,`referensi_id`);

--
-- Indeks untuk tabel `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_documents_member` (`member_id`),
  ADD KEY `idx_documents_jenis` (`jenis_dokumen`),
  ADD KEY `idx_documents_referensi` (`referensi_tabel`,`referensi_id`),
  ADD KEY `idx_documents_is_verified` (`is_verified`),
  ADD KEY `fk_documents_verified_by` (`verified_by`);

--
-- Indeks untuk tabel `installments`
--
ALTER TABLE `installments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_installments_loan_angsuran` (`loan_id`,`angsuran_ke`),
  ADD KEY `idx_installments_loan` (`loan_id`),
  ADD KEY `idx_installments_member` (`member_id`),
  ADD KEY `idx_installments_jatuh_tempo` (`tanggal_jatuh_tempo`),
  ADD KEY `idx_installments_status` (`status`),
  ADD KEY `fk_installments_dibayar_ke` (`dibayar_ke`);

--
-- Indeks untuk tabel `loans`
--
ALTER TABLE `loans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_loans_nomor` (`nomor_pinjaman`),
  ADD KEY `idx_loans_member` (`member_id`),
  ADD KEY `idx_loans_status` (`status`),
  ADD KEY `idx_loans_tanggal_pengajuan` (`tanggal_pengajuan`),
  ADD KEY `idx_loans_jatuh_tempo` (`tanggal_jatuh_tempo`),
  ADD KEY `fk_loans_reviewed_by` (`reviewed_by`);

--
-- Indeks untuk tabel `members`
--
ALTER TABLE `members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_members_user_id` (`user_id`),
  ADD UNIQUE KEY `uq_members_nomor` (`nomor_anggota`),
  ADD UNIQUE KEY `uq_members_nik` (`nik`),
  ADD KEY `idx_members_status` (`status_keanggotaan`),
  ADD KEY `idx_members_tanggal_bergabung` (`tanggal_bergabung`);

--
-- Indeks untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user` (`user_id`),
  ADD KEY `idx_notifications_is_read` (`is_read`),
  ADD KEY `idx_notifications_tipe` (`tipe`),
  ADD KEY `idx_notifications_created` (`created_at`);

--
-- Indeks untuk tabel `savings`
--
ALTER TABLE `savings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_savings_member` (`member_id`),
  ADD KEY `idx_savings_jenis` (`jenis_simpanan`),
  ADD KEY `idx_savings_tanggal` (`tanggal_transaksi`),
  ADD KEY `idx_savings_status` (`status`),
  ADD KEY `idx_savings_referensi` (`referensi_no`),
  ADD KEY `fk_savings_approved_by` (`approved_by`);

--
-- Indeks untuk tabel `shu_distributions`
--
ALTER TABLE `shu_distributions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_shu_member_periode` (`member_id`,`periode_tahun`),
  ADD KEY `idx_shu_periode` (`periode_tahun`),
  ADD KEY `idx_shu_status` (`status`),
  ADD KEY `fk_shu_created_by` (`created_by`);

--
-- Indeks untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_transactions_nomor` (`nomor_transaksi`),
  ADD KEY `idx_transactions_member` (`member_id`),
  ADD KEY `idx_transactions_jenis` (`jenis`),
  ADD KEY `idx_transactions_kategori` (`kategori`),
  ADD KEY `idx_transactions_tanggal` (`tanggal`),
  ADD KEY `fk_transactions_dicatat_oleh` (`dicatat_oleh`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_username` (`username`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_is_active` (`is_active`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key (BIGINT karena volume tinggi)', AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key', AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `installments`
--
ALTER TABLE `installments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key', AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT untuk tabel `loans`
--
ALTER TABLE `loans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key', AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `members`
--
ALTER TABLE `members`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key', AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key', AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `savings`
--
ALTER TABLE `savings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key', AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT untuk tabel `shu_distributions`
--
ALTER TABLE `shu_distributions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key', AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key', AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key', AUTO_INCREMENT=11;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `fk_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `fk_documents_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_documents_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `installments`
--
ALTER TABLE `installments`
  ADD CONSTRAINT `fk_installments_dibayar_ke` FOREIGN KEY (`dibayar_ke`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_installments_loan` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_installments_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `loans`
--
ALTER TABLE `loans`
  ADD CONSTRAINT `fk_loans_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_loans_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `members`
--
ALTER TABLE `members`
  ADD CONSTRAINT `fk_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `savings`
--
ALTER TABLE `savings`
  ADD CONSTRAINT `fk_savings_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_savings_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `shu_distributions`
--
ALTER TABLE `shu_distributions`
  ADD CONSTRAINT `fk_shu_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_shu_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `fk_transactions_dicatat_oleh` FOREIGN KEY (`dicatat_oleh`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transactions_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
