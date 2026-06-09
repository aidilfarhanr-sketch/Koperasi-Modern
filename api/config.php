<?php
// RaresMaju API config — edit jika port/user/password MySQL berbeda.
declare(strict_types=1);

ini_set('display_errors', '0');
error_reporting(E_ALL);

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

header('Content-Type: application/json; charset=utf-8');

const DB_HOST = '127.0.0.1';
const DB_NAME = 'koperasi_raresmaju';
const DB_USER = 'root';
const DB_PASS = '';
const DB_PORT = '3306';

function db(): PDO {
    static $pdo = null;
    if ($pdo instanceof PDO) return $pdo;

    $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=utf8mb4';
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    return $pdo;
}

function out(array $payload, int $status = 200): void {
    http_response_code($status);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function ok($data = null, string $message = 'OK'): void {
    out(['success' => true, 'message' => $message, 'data' => $data]);
}

function fail(string $message = 'Terjadi kesalahan', int $status = 400, $data = null): void {
    out(['success' => false, 'message' => $message, 'data' => $data], $status);
}

function input(): array {
    $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
    if (stripos($contentType, 'application/json') !== false) {
        $raw = file_get_contents('php://input');
        $json = json_decode($raw ?: '{}', true);
        return is_array($json) ? $json : [];
    }
    return $_POST ?: [];
}

function action(): string {
    return $_GET['action'] ?? '';
}

function current_user(): ?array {
    if (empty($_SESSION['user_id'])) return null;
    $sql = "SELECT u.id AS user_id, u.username, u.email, u.role, u.is_active,
                   m.id AS member_id, m.nomor_anggota, m.nama_lengkap, m.no_hp, m.alamat, m.pekerjaan
            FROM users u
            LEFT JOIN members m ON m.user_id = u.id
            WHERE u.id = ?";
    $stmt = db()->prepare($sql);
    $stmt->execute([$_SESSION['user_id']]);
    $user = $stmt->fetch();
    return $user ?: null;
}

function require_user(): array {
    $user = current_user();
    if (!$user) fail('Belum login / sesi habis', 401);
    return $user;
}

function is_admin(array $user): bool {
    return in_array($user['role'] ?? '', ['admin', 'pengurus'], true);
}

function money($v): float {
    return (float)($v ?? 0);
}

function next_nomor(string $prefix): string {
    return $prefix . '-' . date('Ymd') . '-' . substr((string)time(), -5);
}

function log_activity(?int $userId, string $aksi, string $modul, string $deskripsi, string $status = 'Sukses'): void {
    try {
        $stmt = db()->prepare("INSERT INTO activity_logs (user_id, aksi, modul, deskripsi, ip_address, user_agent, status)
                               VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([
            $userId,
            $aksi,
            $modul,
            $deskripsi,
            $_SERVER['REMOTE_ADDR'] ?? null,
            $_SERVER['HTTP_USER_AGENT'] ?? null,
            $status
        ]);
    } catch (Throwable $e) {
        // jangan gagalkan API hanya karena log gagal
    }
}

function upload_doc(?int $memberId, ?int $refId, string $refTable, string $field, string $jenis): ?array {
    if (empty($_FILES[$field]) || ($_FILES[$field]['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) return null;
    $f = $_FILES[$field];
    if ($f['error'] !== UPLOAD_ERR_OK) fail("Upload $jenis gagal.", 400);
    $allowed = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
        'application/pdf' => 'pdf',
    ];
    $mime = mime_content_type($f['tmp_name']);
    if (!isset($allowed[$mime])) fail("$jenis harus JPG, PNG, WEBP, atau PDF.", 400);
    if ((int)$f['size'] > 2 * 1024 * 1024) fail("$jenis maksimal 2MB.", 400);

    $dir = __DIR__ . '/uploads';
    if (!is_dir($dir)) mkdir($dir, 0775, true);

    $ext = $allowed[$mime];
    $safe = preg_replace('/[^a-zA-Z0-9_.-]/', '_', $f['name']);
    $stored = date('YmdHis') . '_' . bin2hex(random_bytes(4)) . '_' . $safe;
    $dest = $dir . '/' . $stored;
    if (!move_uploaded_file($f['tmp_name'], $dest)) fail("Gagal menyimpan $jenis.", 500);

    try {
        $stmt = db()->prepare("INSERT INTO documents
          (member_id, referensi_id, referensi_tabel, jenis_dokumen, nama_file, nama_simpan, path_file, mime_type, ukuran_file)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$memberId, $refId, $refTable, $jenis, $f['name'], $stored, 'api/uploads/' . $stored, $mime, (int)$f['size']]);
    } catch (Throwable $e) {}

    return ['nama_file' => $f['name'], 'path' => 'api/uploads/' . $stored, 'mime_type' => $mime, 'ukuran_file' => (int)$f['size']];
}
