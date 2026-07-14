path = "lib/page/channel_detail_page.dart"
with open(path, "r") as f:
    lines = f.readlines()

start = 157 - 1   # 0-indexed
end = 176         # slice üst sınırı (176. satır dahil)

new_func = '''  Future<void> _togglePin(Map<String, dynamic> post) async {
    final channelId = widget.channel['id'];
    final bucket = 'channel_posts:$channelId';
    final postId = post['id'].toString();
    final isPinned = post['pinned'] == true;

    if (!isPinned) {
      for (final p in _posts) {
        if (p['pinned'] == true && p['id'].toString() != postId) {
          p['pinned'] = false;
          await ByBugDatabase.update(bucket, p['id'].toString(), p);
        }
      }
    }

    final updated = Map<String, dynamic>.from(post);
    updated['pinned'] = !isPinned;
    await ByBugDatabase.update(bucket, postId, updated);

    setState(() {
      final idx = _posts.indexWhere((p) => p['id'].toString() == postId);
      if (idx != -1) _posts[idx]['pinned'] = !isPinned;
    });
  }
'''

lines[start:end] = [new_func]

with open(path, "w") as f:
    f.writelines(lines)

print("Değiştirildi. Yeni satır sayısı:", len(lines))
