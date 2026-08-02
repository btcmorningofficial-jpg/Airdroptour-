<?php
require_once __DIR__ . '/../cors.php';
require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../jwt.php';

$uid = requireAuth();

$body = readJsonBody();
$notifTag = trim($body['notif_tag'] ?? '');

if ($notifTag === '' || strpos($notifTag, $uid . ':') !== 0) {
    echo json_encode(['status' => 0, 'message' => 'Invalid notification']);
    exit;
}

$db = getDb();
$stmt = $db->prepare('DELETE FROM kv_store WHERE bucket = ? AND tag = ?');
$stmt->execute(['notifications', $notifTag]);

echo json_encode(['status' => 1]);
