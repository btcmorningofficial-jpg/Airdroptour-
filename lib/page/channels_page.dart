import 'package:flutter/material.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/page/channel_detail_page.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _creating = false;
  bool _loadingList = true;
  String? _error;
  String? _uid;
  List<Map<String, dynamic>> _channels = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _uid = await ByBugAuth.getUID();
    await _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() => _loadingList = true);
    final result = await ByBugChannelList.listChannels();
    if (result[0] == 1) {
      final List<dynamic> items = result[1];
      setState(() {
        _channels = items.map((e) => Map<String, dynamic>.from(e)).toList();
        _loadingList = false;
      });
    } else {
      setState(() => _loadingList = false);
    }
  }

  Future<void> _createChannel() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() {
      _creating = true;
      _error = null;
    });

    final result = await ByBugChannel.createChannel(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
    );

    setState(() => _creating = false);

    if (result[0] == 1) {
      _nameController.clear();
      _descController.clear();
      await _loadChannels();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Channel created successfully')),
        );
      }
    } else {
      setState(() => _error = result[1]?.toString() ?? 'Something went wrong');
    }
  }

  void _openChannel(Map<String, dynamic> channel) {
    if (_uid == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChannelDetailPage(channel: channel, currentUid: _uid!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: h1('Channels'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadChannels,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            h3('Create a new channel'),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: const InputDecoration(
                hintText: 'Channel name',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              style: TextStyle(color: textColor),
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
              ),
            ),
            const SizedBox(height: 10),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: _creating ? null : _createChannel,
              child: _creating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Channel'),
            ),
            const SizedBox(height: 30),
            h3('All channels'),
            const SizedBox(height: 10),
            if (_loadingList)
              const Center(child: CircularProgressIndicator())
            else if (_channels.isEmpty)
              const Text('No channels yet')
            else
              ..._channels.map((channel) => GestureDetector(
                    onTap: () => _openChannel(channel),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: navColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  channel['name']?.toString() ?? '',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if ((channel['description'] ?? '').toString().isNotEmpty)
                                  Text(
                                    channel['description'].toString(),
                                    style: TextStyle(color: textColor.withOpacity(0.6)),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: textColor),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
