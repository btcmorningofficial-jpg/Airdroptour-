import 'package:flutter/material.dart';
import '../services/bybugdb_bridge.dart';

class ChannelInfoPage extends StatefulWidget {
  final Map<String, dynamic> channel;
  final String currentUid;

  const ChannelInfoPage({
    super.key,
    required this.channel,
    required this.currentUid,
  });

  @override
  State<ChannelInfoPage> createState() => _ChannelInfoPageState();
}

class _ChannelInfoPageState extends State<ChannelInfoPage> {
  List<dynamic> _members = [];
  int _memberCount = 0;
  bool _loading = true;
  bool _isSubscribed = false;

  bool get _isOwner => widget.channel['owner_id'] == widget.currentUid;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final result = await ByBugChannel.getChannelMembers(widget.channel['id']);
    if (result[0] == 1 && mounted) {
      setState(() {
        _members = result[1];
        _memberCount = result[2];
        _isSubscribed = result[3];
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  int get _adminCount {
    final adminIds = List<String>.from(widget.channel['admin_ids'] ?? []);
    return adminIds.length;
  }

  Future<void> _editDescription() async {
    final controller = TextEditingController(
      text: (widget.channel['description'] ?? '').toString(),
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit description'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 200,
          decoration: const InputDecoration(hintText: 'Channel description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;

    final res = await ByBugChannel.updateChannel(
      channelId: widget.channel['id'],
      name: widget.channel['name'],
      description: result,
    );

    if (res[0] == 1 && mounted) {
      setState(() {
        widget.channel['description'] = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description updated')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed')),
      );
    }
  }

  Future<void> _toggleAdmin(String targetUid, bool isAdmin) async {
    final result = isAdmin
        ? await ByBugChannel.removeAdmin(
            channelId: widget.channel['id'], targetUid: targetUid)
        : await ByBugChannel.addAdmin(
            channelId: widget.channel['id'], targetUid: targetUid);

    if (result[0] == 1 && mounted) {
      setState(() {
        final adminIds =
            List<String>.from(widget.channel['admin_ids'] ?? []);
        if (isAdmin) {
          adminIds.remove(targetUid);
        } else {
          adminIds.add(targetUid);
        }
        widget.channel['admin_ids'] = adminIds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.channel['name'] ?? '').toString();
    final description = (widget.channel['description'] ?? '').toString();
    final photo = (widget.channel['avatar_url'] ?? '').toString();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Channel Info'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage:
                            photo.isNotEmpty ? NetworkImage(photo) : null,
                        child: photo.isEmpty
                            ? const Icon(Icons.groups, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_memberCount subscribers ${String.fromCharCode(183)} $_adminCount admins',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionCard(
                  title: 'Description',
                  trailing: _isOwner
                      ? IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: _editDescription,
                        )
                      : null,
                  child: Text(
                    description.isNotEmpty
                        ? description
                        : 'No description yet',
                    style: TextStyle(
                      color: description.isNotEmpty
                          ? Colors.white70
                          : Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: 'Members ($_memberCount)',
                  child: Column(
                    children: _members.take(6).map((m) {
                      final mName = (m['name'] ?? '').toString();
                      final mPhoto = (m['photo'] ?? '').toString();
                      final mUid = (m['uid'] ?? '').toString();
                      final adminIds = List<String>.from(
                          widget.channel['admin_ids'] ?? []);
                      final isAdmin = adminIds.contains(mUid);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage:
                              mPhoto.isNotEmpty ? NetworkImage(mPhoto) : null,
                          child: mPhoto.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          mName.isNotEmpty ? mName : mUid,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: isAdmin
                            ? const Text('Admin',
                                style: TextStyle(
                                    color: Colors.amber, fontSize: 12))
                            : null,
                        trailing: (_isOwner && mUid != widget.currentUid)
                            ? IconButton(
                                icon: Icon(
                                  isAdmin
                                      ? Icons.remove_moderator
                                      : Icons.add_moderator,
                                  size: 20,
                                ),
                                onPressed: () => _toggleAdmin(mUid, isAdmin),
                              )
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
