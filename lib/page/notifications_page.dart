import 'package:flutter/material.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/theme/color.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  final Set<String> _responding = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ByBugInvite.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = list;
      _loading = false;
    });
  }

  Future<void> _respond(Map<String, dynamic> n, bool accept) async {
    final tag = n['notif_tag'].toString();
    setState(() => _responding.add(tag));

    final result = await ByBugInvite.respondToChannelInvite(
      channelId: n['channel_id'].toString(),
      accept: accept,
    );

    if (!mounted) return;
    setState(() => _responding.remove(tag));

    if (result[0] == 1) {
      await ByBugInvite.markNotificationRead(tag);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accept ? 'You joined the channel' : 'Invite declined')),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result[1]?.toString() ?? 'Action failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.notifications_none, color: Colors.white38, size: 48),
                      SizedBox(height: 12),
                      Text('No notifications', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final type = n['type'] ?? '';
                      final tag = n['notif_tag'].toString();
                      final isResponding = _responding.contains(tag);
                      final isRead = n['read'] == true;

                      if (type == 'channel_invite') {
                        final channelName = (n['channel_name'] ?? 'Channel').toString();
                        return ListTile(
                          tileColor: isRead ? null : Colors.white.withOpacity(0.03),
                          leading: CircleAvatar(
                            backgroundColor: navColor.withOpacity(0.2),
                            child: const Icon(Icons.groups, color: Colors.white70),
                          ),
                          title: Text(
                            'Do you want to join $channelName?',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            'Channel invite',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          trailing: isResponding
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                      onPressed: () => _respond(n, true),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                      onPressed: () => _respond(n, false),
                                    ),
                                  ],
                                ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          n['message']?.toString() ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
