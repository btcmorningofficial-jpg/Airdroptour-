<?php
require_once __DIR__ . '/../cors.php';
require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../jwt.php';

$uid = requireAuth();

$db = getDb();
$stmt = $db->prepare('DELETE FROM kv_store WHERE bucket = ? AND tag LIKE ?');
$stmt->execute(['notifications', $uid . ':%']);

echo json_encode(['status' => 1]);
