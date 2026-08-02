<?php
require_once __DIR__ . '/../cors.php';
require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../jwt.php';

$uid = requireAuth();

$body = readJsonBody();
$channelId = trim($body['channel_id'] ?? '');
$type = trim($body['type'] ?? 'text'); // text | voice | image
$content = $body['content'] ?? '';
$caption = trim($body['caption'] ?? '');

if ($channelId === '' || $content === '') {
    echo json_encode(['status' => 0, 'message' => 'channel_id ve content gerekli']);
    exit;
}

$db = getDb();

// Kanalın sahibi kontrolü
$stmt = $db->prepare('SELECT value FROM kv_store WHERE bucket = ? AND tag = ?');
$stmt->execute(['channels', $channelId]);
$row = $stmt->fetch();

if (!$row) {
    echo json_encode(['status' => 0, 'message' => 'Kanal bulunamadı']);
    exit;
}

$channel = json_decode($row['value'], true);
if ($channel['owner_id'] !== $uid) {
    http_response_code(403);
    echo json_encode(['status' => 0, 'message' => 'Sadece kanal sahibi paylaşım yapabilir']);
    exit;
}

$postId = (string) (int)(microtime(true) * 1000);

$postData = [
    'id' => $postId,
    'channel_id' => $channelId,
    'type' => $type,
    'content' => $content,
    'caption' => $caption,
    'reactions' => [],
    'created_at' => date('c'),
];

$stmt = $db->prepare('INSERT INTO kv_store (bucket, tag, value) VALUES (?, ?, ?)');
$stmt->execute(['channel_posts:' . $channelId, $postId, json_encode($postData, JSON_UNESCAPED_UNICODE)]);

echo json_encode(['status' => 1, 'post' => $postData]);
