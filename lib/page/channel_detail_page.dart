import 'dart:async';
import 'package:flutter/material.dart';
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
                            child: Text(
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
