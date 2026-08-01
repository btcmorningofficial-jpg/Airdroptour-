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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
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

  Future<void> _sendInvites() async {
    if (_selected.isEmpty) return;
    setState(() => _sending = true);
    final result = await ByBugInvite.sendChannelInvites(
      channelId: widget.channelId,
      targetUids: _selected.toList(),
    );
    if (!mounted) return;
    setState(() => _sending = false);

    if (result[0] == 1) {
      final sent = (result[1] as List).length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$sent kisiye davet gonderildi')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result[1]?.toString() ?? 'Davet gonderilemedi')),
      );
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
        title: const Text('Uye Davet Et'),
        actions: [
          TextButton(
            onPressed: _sending ? null : _sendInvites,
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Gonder (${_selected.length})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Kullanici ara...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(
                        child: Text(
                          'Davet edilebilecek kullanici bulunamadi',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final u = _users[index];
                          final uid = u['uid'].toString();
                          final name = (u['name'] ?? 'Kullanici').toString();
                          final photo = (u['photo'] ?? '').toString();
                          final isSelected = _selected.contains(uid);
                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: navColor,
                            checkColor: Colors.white,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  if (_selected.length >= 100) return;
                                  _selected.add(uid);
                                } else {
                                  _selected.remove(uid);
                                }
                              });
                            },
                            secondary: CircleAvatar(
                              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                              child: photo.isEmpty ? const Icon(Icons.person) : null,
                            ),
                            title: Text(name, style: const TextStyle(color: Colors.white)),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}