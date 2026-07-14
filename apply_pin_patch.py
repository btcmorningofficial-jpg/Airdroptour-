path = "lib/page/channel_detail_page.dart"
with open(path, "r") as f:
    content = f.read()

edits = []

# 1) _sortedPosts getter
old1 = """  bool get _isOwner => widget.channel['owner_id'] == widget.currentUid;"""
new1 = """  bool get _isOwner => widget.channel['owner_id'] == widget.currentUid;

  List<Map<String, dynamic>> get _sortedPosts {
    final pinned = _posts.where((p) => p['pinned'] == true).toList();
    final rest = _posts.where((p) => p['pinned'] != true).toList();
    return [...pinned, ...rest];
  }"""
edits.append(("sortedPosts getter", old1, new1))

# 2) _togglePin function - appended after _togglePlay
old2 = """  Future<void> _togglePlay(String postId, String url) async {
    if (_playingPostId == postId) {
      await _player.stop();
      setState(() => _playingPostId = null);
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() => _playingPostId = postId);
      _player.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _playingPostId = null);
      });
    }
  }"""
new2 = """  Future<void> _togglePlay(String postId, String url) async {
    if (_playingPostId == postId) {
      await _player.stop();
      setState(() => _playingPostId = null);
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() => _playingPostId = postId);
      _player.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _playingPostId = null);
      });
    }
  }

  Future<void> _togglePin(Map<String, dynamic> post) async {
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
  }"""
edits.append(("togglePin fonksiyonu", old2, new2))

# 3) itemCount
old3 = """                        itemCount: _posts.length,"""
new3 = """                        itemCount: _sortedPosts.length,"""
edits.append(("itemCount", old3, new3))

# 4) itemBuilder wrap with GestureDetector
old4 = """                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Container("""
new4 = """                        itemBuilder: (context, index) {
                          final post = _sortedPosts[index];
                          return GestureDetector(
                            onLongPress:

cd ~/shared/Airdroptour-
cat > apply_pin_patch.py << 'PYEOF'
path = "lib/page/channel_detail_page.dart"
with open(path, "r") as f:
    content = f.read()

edits = []

# 1) _sortedPosts getter
old1 = """  bool get _isOwner => widget.channel['owner_id'] == widget.currentUid;"""
new1 = """  bool get _isOwner => widget.channel['owner_id'] == widget.currentUid;

  List<Map<String, dynamic>> get _sortedPosts {
    final pinned = _posts.where((p) => p['pinned'] == true).toList();
    final rest = _posts.where((p) => p['pinned'] != true).toList();
    return [...pinned, ...rest];
  }"""
edits.append(("sortedPosts getter", old1, new1))

# 2) _togglePin function - appended after _togglePlay
old2 = """  Future<void> _togglePlay(String postId, String url) async {
    if (_playingPostId == postId) {
      await _player.stop();
      setState(() => _playingPostId = null);
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() => _playingPostId = postId);
      _player.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _playingPostId = null);
      });
    }
  }"""
new2 = """  Future<void> _togglePlay(String postId, String url) async {
    if (_playingPostId == postId) {
      await _player.stop();
      setState(() => _playingPostId = null);
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() => _playingPostId = postId);
      _player.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _playingPostId = null);
      });
    }
  }

  Future<void> _togglePin(Map<String, dynamic> post) async {
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
  }"""
edits.append(("togglePin fonksiyonu", old2, new2))

# 3) itemCount
old3 = """                        itemCount: _posts.length,"""
new3 = """                        itemCount: _sortedPosts.length,"""
edits.append(("itemCount", old3, new3))

# 4) itemBuilder wrap with GestureDetector
old4 = """                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Container("""
new4 = """                        itemBuilder: (context, index) {
                          final post = _sortedPosts[index];
                          return GestureDetector(
                            onLongPress:
                                _isOwner ? () => _togglePin(post) : null,
                            child: Container("""
edits.append(("itemBuilder wrap", old4, new4))

# 5) decoration - pin border
old5 = """                            decoration: BoxDecoration(
                              color: navColor,
                              borderRadius: BorderRadius.circular(10),
                            ),"""
new5 = """                            decoration: BoxDecoration(
                              color: navColor,
                              borderRadius: BorderRadius.circular(10),
                              border: post['pinned'] == true
                                  ? Border.all(color: Colors.amber, width: 2)
                                  : null,
                            ),"""
edits.append(("pin border", old5, new5))

# 6) closing paren for GestureDetector
old6 = """                                : Text(
                                    post['content']?.toString() ?? '',
                                    style: TextStyle(color: textColor),
                                  ),
                          );
                        },"""
new6 = """                                : Text(
                                    post['content']?.toString() ?? '',
                                    style: TextStyle(color: textColor),
                                  ),
                            ),
                          );
                        },"""
edits.append(("kapanis parantezi", old6, new6))

ok = True
for name, old, new in edits:
    count = content.count(old)
    if count != 1:
        print(f"UYARI [{name}]: eslesme sayisi {count} (1 olmali) - atlaniyor")
        ok = False
        continue
    content = content.replace(old, new, 1)
    print(f"OK: {name} uygulandi")

with open(path, "w") as f:
    f.write(content)

print("Bitti.")
