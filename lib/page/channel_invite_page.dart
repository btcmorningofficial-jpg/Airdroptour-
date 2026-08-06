import 'dart:async';
import 'package:flutter/material.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/theme/color.dart';

class ChannelInvitePage extends StatefulWidget {
  final String channelId;
  const ChannelInvitePage({super.key, required this.channelId});

  @override
  State<ChannelInvitePage> createState() => _ChannelInvitePageState();
}

class _ChannelInvitePageState extends State<ChannelInvitePage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _sending = false;
  String? _errorText;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() {
      _loading = true;
      _errorText = null;
    });
    final users = await ByBugInvite.getInvitableUsers(
      channelId: widget.channelId,
      search: search,
    );
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _load(search: value));
  }

  void _toggleSelect(String uid) {
    setState(() {
      if (_selected.contains(uid)) {
        _selected.remove(uid);
      } else {
        if (_selected.length >= 100) {
          _errorText = 'You can select up to 100 people at a time';
          return;
        }
        _errorText = null;
        _selected.add(uid);
      }
    });
  }

  Future<void> _sendInvites() async {
    if (_selected.isEmpty) return;
    setState(() {
      _sending = true;
      _errorText = null;
    });
    final result = await ByBugInvite.sendChannelInvites(
      channelId: widget.channelId,
      targetUids: _selected.toList(),
    );
    if (!mounted) return;
    setState(() => _sending = false);

    if (result[0] == 1) {
      final sentList = result[1] as List;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invited ${sentList.length} people')),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorText = result[1]?.toString() ?? 'Could not send invites';
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Invite Members', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: ElevatedButton(
                onPressed: (_selected.isEmpty || _sending) ? null : _sendInvites,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navColor,
                  disabledBackgroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Send (${_selected.length})',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ),
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${_selected.length} selected',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _selected.clear()),
                    child: const Text('Clear selection', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.person_search, color: Colors.white38, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'No users available to invite',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _load(search: _searchController.text),
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final u = _users[index];
                            final uid = u['uid'].toString();
                            final name = (u['name'] ?? 'User').toString();
                            final photo = (u['photo'] ?? '').toString();
                            final isSelected = _selected.contains(uid);
                            return CheckboxListTile(
                              value: isSelected,
                              activeColor: navColor,
                              checkColor: Colors.white,
                              onChanged: (_) => _toggleSelect(uid),
                              secondary: CircleAvatar(
                                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                                child: photo.isEmpty ? const Icon(Icons.person) : null,
                              ),
                              title: Text(name, style: const TextStyle(color: Colors.white)),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
