<?php
require __DIR__ . '/config.php';

try {
    $user = require_user();
    $params = [(int)$user['user_id']];
    $stmt = db()->prepare("SELECT * FROM activity_logs WHERE user_id=? ORDER BY created_at DESC LIMIT 50");
    $stmt->execute($params);
    ok($stmt->fetchAll());
} catch (Throwable $e) {
    fail('Activity log error: ' . $e->getMessage(), 500);
}
