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
  final _searchController = TextEditingController();
  bool _creating = false;
  bool _loadingList = true;
  String? _error;
  String? _uid;
  List<Map<String, dynamic>> _channels = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _init();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _uid = await ByBugAuth.getUID();
    await _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() => _loadingList = true);
    final result = await ByBugChannel.listChannels();
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

  List<Map<String, dynamic>> get _filteredChannels {
    if (_searchQuery.isEmpty) return _channels;
    return _channels.where((c) {
      final name = (c['name'] ?? '').toString().toLowerCase();
      final desc = (c['description'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) || desc.contains(_searchQuery);
    }).toList();
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

  void _showChannelMenu(Map<String, dynamic> channel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: navColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Channel', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteChannel(channel);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteChannel(Map<String, dynamic> channel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: navColor,
        title: Text('Delete Channel', style: TextStyle(color: textColor)),
        content: Text(
          'Are you sure you want to permanently delete "${channel["name"]}"? All messages will be deleted.',
          style: TextStyle(color: textColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: textColor))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await ByBugChannel.deleteChannel(channel['id']);
    if (result[0] == 1) {
      setState(() {
        _channels.removeWhere((c) => c['id'] == channel['id']);
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result[1]?.toString() ?? 'Failed to delete channel')),
      );
    }
  }

  Future<void> _openChannel(Map<String, dynamic> channel) async {
    if (_uid == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChannelDetailPage(channel: channel, currentUid: _uid!),
      ),
    );
    if (mounted) {
      await _loadChannels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: h1('Channels'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadChannels,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Create channel card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: navColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: textColor, size: 20),
                      const SizedBox(width: 8),
                      h3('Create a new channel'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Channel name',
                      hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Description (optional)',
                      hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: _creating ? null : _createChannel,
                      child: _creating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Create Channel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                h3('All channels'),
                const Spacer(),
                Text('${_filteredChannels.length}', style: TextStyle(color: textColor.withOpacity(0.5))),
              ],
            ),
            const SizedBox(height: 10),

            // Search box
            TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search channels...',
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: textColor.withOpacity(0.5)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: textColor.withOpacity(0.5)),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: navColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            if (_loadingList)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredChannels.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.forum_outlined, color: textColor.withOpacity(0.3), size: 48),
                      const SizedBox(height: 10),
                      Text(
                        _searchQuery.isNotEmpty ? 'No channels match your search' : 'No channels yet',
                        style: TextStyle(color: textColor.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._filteredChannels.map((channel) => GestureDetector(
                    onTap: () => _openChannel(channel),
                    onLongPress: channel['owner_id'] == _uid ? () => _showChannelMenu(channel) : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: navColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white24,
                            backgroundImage: (channel['avatar_url'] != null && channel['avatar_url'].toString().isNotEmpty)
                                ? NetworkImage(channel['avatar_url'].toString())
                                : null,
                            child: (channel['avatar_url'] == null || channel['avatar_url'].toString().isEmpty)
                                ? Text(
                                    (channel['name']?.toString().isNotEmpty == true)
                                        ? channel['name'].toString()[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  channel['name']?.toString() ?? '',
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                if ((channel['description'] ?? '').toString().isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    channel['description'].toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: textColor.withOpacity(0.4)),
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
