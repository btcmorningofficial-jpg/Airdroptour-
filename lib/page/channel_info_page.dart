import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/theme/color.dart';

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
  bool _loading = true;
  List<dynamic> _members = [];
  int _memberCount = 0;
  bool _isSubscribed = false;

  bool get _isOwner => widget.channel['owner_id'] == widget.currentUid;
  List<String> get _adminIds =>
      List<String>.from(widget.channel['admin_ids'] ?? []);
  bool get _isAdmin => _adminIds.contains(widget.currentUid);

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final result = await ByBugChannel.getChannelMembers(widget.channel['id']);
    if (!mounted) return;
    setState(() {
      _members = result[1] ?? [];
      _memberCount = result[2] ?? 0;
      _isSubscribed = result[3] ?? false;
      _loading = false;
    });
  }

  void _copyInviteLink() {
    final link = 'https://btcmorning.com/channel/${widget.channel['id']}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Davet linki kopyalandı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.channel['name'] ?? 'Channel';
    final description = (widget.channel['description'] ?? '').toString();
    final avatarUrl = widget.channel['avatar_url'];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text('Channel Info',
            style: GoogleFonts.poppins(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                        radius: 44,
                        backgroundColor: navColor,
                        backgroundImage: (avatarUrl != null &&
                                avatarUrl.toString().isNotEmpty)
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: (avatarUrl == null ||
                                avatarUrl.toString().isEmpty)
                            ? const Icon(Icons.groups,
                                size: 40, color: Colors.white70)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_memberCount members',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (description.isNotEmpty) ...[
                  Text('Description',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: navColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      description,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text('Invite Link',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: navColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'btcmorning.com/channel/${widget.channel['id']}',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy,
                            color: Colors.white70, size: 18),
                        onPressed: _copyInviteLink,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _statCard('Members', '$_memberCount'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard('Admins', '${_adminIds.length}'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Members',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                ..._members.map((m) => _memberTile(m)),
              ],
            ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: navColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _memberTile(dynamic m) {
    final map = (m is Map) ? Map<String, dynamic>.from(m) : <String, dynamic>{};
    final uid = map['uid']?.toString() ?? map['user_id']?.toString() ?? '';
    final displayName =
        map['name'] ?? map['username'] ?? map['email'] ?? 'User';
    final avatar = map['avatar_url'];
    final isOwnerRow = uid == widget.channel['owner_id'];
    final isAdminRow = _adminIds.contains(uid);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: navColor,
            backgroundImage:
                (avatar != null && avatar.toString().isNotEmpty)
                    ? NetworkImage(avatar)
                    : null,
            child: (avatar == null || avatar.toString().isEmpty)
                ? const Icon(Icons.person, size: 16, color: Colors.white70)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              displayName.toString(),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isOwnerRow)
            _badge('Owner', Colors.amber)
          else if (isAdminRow)
            _badge('Admin', Colors.lightBlueAccent),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: GoogleFonts.poppins(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
