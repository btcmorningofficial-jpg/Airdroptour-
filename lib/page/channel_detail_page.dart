import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/text.dart';

Map<String, dynamic> _asReactionsMap(dynamic v) => (v is Map) ? Map<String, dynamic>.from(v) : <String, dynamic>{};

class ChannelDetailPage extends StatefulWidget {
  final Map<String, dynamic> channel;
  final String currentUid;

  const ChannelDetailPage({
    super.key,
    required this.channel,
    required this.currentUid,
  });

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  final List<Map<String, dynamic>> _posts = [];
  final _postController = TextEditingController();
  bool _posting = false;
  bool _loading = true;
  String _lastId = '0';

  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  bool _isRecording = false;
  bool _isUploadingVoice = false;
  String? _playingPostId;

  bool get _isOwner => widget.channel['owner_id'] == widget.currentUid;

  String? _avatarUrl;

  Future<void> _changeAvatar() async {
    if (!_isOwner) return;
    final path = await pickImage();
    if (path == null) return;
    final result = await ByBugChannel.updateAvatar(channelId: widget.channel['id'], filePath: path);
    if (result[0] == 1) {
      setState(() { _avatarUrl = result[1]['avatar_url']; });
    } else {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result[1].toString()))); }
    }
  }

  List<Map<String, dynamic>> get _sortedPosts {
    final pinned = _posts.where((p) => p['pinned'] == true).toList();
    final rest = _posts.where((p) => p['pinned'] != true).toList();
    return [...pinned, ...rest];
  }

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.channel['avatar_url'];
    _loadInitial();
    _loadMembers();
  }

  @override
  void dispose() {
    ByBugChannel.stopStream();
    _postController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final result = await ByBugChannel.getFeed(widget.channel['id']);
    if (result[0] == 1) {
      final List<dynamic> items = result[1];
      setState(() {
        _posts.addAll(items.map((e) => Map<String, dynamic>.from(e)));
        if (_posts.isNotEmpty) {
          _lastId = _posts.last['id'].toString();
        }
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }

    ByBugChannel.streamChannel(
      channelId: widget.channel['id'],
      afterId: _lastId,
      onPost: (post) {
        if (!mounted) return;
        setState(() {
          _posts.add(post);
        });
      },
    );
  }

  Future<void> _loadMembers() async {
    final result = await ByBugChannel.getChannelMembers(widget.channel['id']);
    if (result[0] == 1 && mounted) {
      setState(() {
        _members = result[1];
        _memberCount = result[2];
        _isSubscribed = result[3];
      });
    }
  }

  Future<void> _toggleSubscription() async {
    final result = _isSubscribed
        ? await ByBugChannel.unsubscribeFromChannel(widget.channel['id'])
        : await ByBugChannel.subscribeToChannel(widget.channel['id']);
    if (result[0] == 1) {
      await _loadMembers();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result[1]?.toString() ?? 'Islem basarisiz')),
      );
    }
  }

  void _showMembersList() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: 400,
          child: _members.isEmpty
              ? const Center(child: Text('Henuz uye yok'))
              : ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final m = _members[index];
                    final name = (m['name'] ?? '').toString();
                    final photo = (m['photo'] ?? '').toString();
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                        child: photo.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(name.isNotEmpty ? name : (m['uid']?.toString() ?? '')),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _sendPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);

    final result = await ByBugChannel.postToChannel(
      channelId: widget.channel['id'],
      content: text,
    );

    setState(() => _posting = false);

    if (result[0] == 1) {
      _postController.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result[1]?.toString() ?? 'Failed to post')),
      );
    }
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecordingAndSend() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path == null) return;

    setState(() => _isUploadingVoice = true);
    final url = await ByBugStorage.uploadFile(path);
    setState(() => _isUploadingVoice = false);

        if (url == null || url.startsWith("ERR:")) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(url ?? 'unknown error')),
        );
      }
      return;
    }

    await ByBugChannel.postToChannel(
      channelId: widget.channel['id'],
      content: url,
      type: 'audio',
    );
  }

  Future<void> _togglePlay(String postId, String url) async {
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

  Future<void> _toggleReaction(Map<String, dynamic> post, String emoji) async {
    final channelId = widget.channel['id'];
    final bucket = 'channel_posts:$channelId';
    final postId = post['id'].toString();
    final uid = widget.currentUid;

    final reactions = _asReactionsMap(post['reactions']);

    for (final e in List<String>.from(reactions.keys)) {
      if (e == emoji) continue;
      final u = List<dynamic>.from(reactions[e] ?? []);
      if (u.remove(uid)) {
        if (u.isEmpty) {
          reactions.remove(e);
        } else {
          reactions[e] = u;
        }
      }
    }

    final users = List<dynamic>.from(reactions[emoji] ?? []);

    if (users.contains(uid)) {
      users.remove(uid);
    } else {
      users.add(uid);
    }

    if (users.isEmpty) {
      reactions.remove(emoji);
    } else {
      reactions[emoji] = users;
    }
    }

    final updated = Map<String, dynamic>.from(post);
    updated['reactions'] = reactions;
    await ByBugDatabase.update(bucket, postId, updated);

    setState(() {
      final idx = _posts.indexWhere((p) => p['id'].toString() == postId);
      if (idx != -1) _posts[idx]['reactions'] = reactions;
    });
  }

  Future<void> _showReactionPicker(Map<String, dynamic> post) async {
    const emojis = [
      '👍', '❤️', '🔥', '😂', '😮', '😢', '🙏', '🎉', '💯', '🚀',
      '💎', '📈', '📉', '🤝', '👀', '💰', '⚡', '🐂', '🐻', '🌕',
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: emojis
              .map((e) => IconButton(
                    onPressed: () => Navigator.pop(ctx, e),
                    icon: Text(e, style: const TextStyle(fontSize: 26)),
                  ))
              .toList(),
        ),
      ),
    );
    if (selected != null) {
      await _toggleReaction(post, selected);
    }
  }

  Widget _buildReactions(Map<String, dynamic> post) {
    final reactions = _asReactionsMap(post['reactions']);
    final uid = widget.currentUid;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          ...reactions.entries.map((entry) {
            final emoji = entry.key;
            final users = List<dynamic>.from(entry.value);
            final reacted = users.contains(uid);
            return GestureDetector(
              onTap: () => _toggleReaction(post, emoji),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      reacted ? Colors.amber.withOpacity(0.3) : navColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: reacted ? Colors.amber : Colors.transparent,
                  ),
                ),
                child: Text(
                  '$emoji ${users.length}',
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: () => _showReactionPicker(post),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: navColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add_reaction_outlined,
                  size: 16, color: textColor),
            ),
          ),
        ],
      ),
    );
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
  }

  void _showPostMenu(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(post['pinned'] == true ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(post['pinned'] == true ? 'Sabitlemeyi kaldir' : 'Sabitle'),
              onTap: () {
                Navigator.pop(ctx);
                _togglePin(post);
              },
            ),
            if (post['type'] != 'audio')
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(ctx);
                  _editPost(post);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _deletePost(post);
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _confirmDeleteChannelFromDetail() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete channel'),
          content: Text('Are you sure you want to permanently delete "${widget.channel['name']}"? All messages will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    final result = await ByBugChannel.deleteChannel(widget.channel['id']);
    if (result[0] == 1) {
      if (mounted) Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result[1]?.toString() ?? 'Channel could not be deleted')),
      );
    }
  }
  Future<void> _deletePost(Map<String, dynamic> post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mesaji sil'),
        content: const Text('Bu mesaji silmek istediginize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    final channelId = widget.channel['id'];
    final bucket = 'channel_posts:$channelId';
    final postId = post['id'].toString();
    await ByBugDatabase.remove(bucket, postId);

    setState(() {
      _posts.removeWhere((p) => p['id'].toString() == postId);
    });
  }

  Future<void> _editPost(Map<String, dynamic> post) async {
    final controller = TextEditingController(text: post['content']?.toString() ?? '');
    final newText = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mesaji duzenle'),
        content: TextField(controller: controller, maxLines: 5, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Kaydet')),
        ],
      ),
    );
    if (newText == null || newText.isEmpty) return;

    final channelId = widget.channel['id'];
    final bucket = 'channel_posts:$channelId';
    final postId = post['id'].toString();
    final updated = Map<String, dynamic>.from(post);
    updated['content'] = newText;
    await ByBugDatabase.update(bucket, postId, updated);

    setState(() {
      final idx = _posts.indexWhere((p) => p['id'].toString() == postId);
      if (idx != -1) _posts[idx]['content'] = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Row(children: [GestureDetector(onTap: _changeAvatar, child: CircleAvatar(radius: 18, backgroundColor: navColor, backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty) ? NetworkImage(_avatarUrl!) : null, child: (_avatarUrl == null || _avatarUrl!.isEmpty) ? const Icon(Icons.groups, size: 18, color: Colors.white70) : null)), const SizedBox(width: 10), Expanded(child: h1(widget.channel['name'] ?? 'Channel'))]),
            actions: [
            TextButton.icon(
              onPressed: _showMembersList,
              icon: const Icon(Icons.people, size: 18, color: Colors.white),
              label: Text('$_memberCount', style: const TextStyle(color: Colors.white)),
            ),
              TextButton(
                onPressed: _toggleSubscription,
                child: Text(
                  _isSubscribed ? 'Ayril' : 'Katil',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            if (_isOwner) IconButton(icon: const Icon(Icons.delete), onPressed: _confirmDeleteChannelFromDetail),
          ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? const Center(child: Text('No posts yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _sortedPosts.length,
                        itemBuilder: (context, index) {
                          final post = _sortedPosts[index];
                          return GestureDetector(
                            onLongPress:
                                _isOwner ? () => _showPostMenu(post) : null,
                            child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: navColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                post['type'] == 'audio'
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _togglePlay(
                                          post['id'].toString(),
                                          post['content']?.toString() ?? '',
                                        ),
                                        icon: Icon(
                                          _playingPostId ==
                                                  post['id'].toString()
                                              ? Icons.stop_circle
                                              : Icons.play_circle,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        'Voice message',
                                        style: TextStyle(color: textColor),
                                      ),
                                    ],
                                  )
                                : Text(
                                    post['content']?.toString() ?? '',
                                    style: TextStyle(color: textColor),
                                  ),
                                _buildReactions(post),
                              ],
                            ),
                  ),
                          );
                        },
                      ),
          ),
            if (_isOwner)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Write a post...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _isUploadingVoice
                        ? null
                        : (_isRecording
                            ? _stopRecordingAndSend
                            : _startRecording),
                    icon: _isUploadingVoice
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: _isRecording ? Colors.red : textColor,
                          ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _posting ? null : _sendPost,
                    icon: _posting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
