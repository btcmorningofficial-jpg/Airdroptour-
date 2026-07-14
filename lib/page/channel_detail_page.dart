import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/text.dart';

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

  @override
  void initState() {
    super.initState();
    _loadInitial();
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

    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload voice message')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: h1(widget.channel['name'] ?? 'Channel'),
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
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: navColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: post['type'] == 'audio'
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
