import 'package:flutter/material.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/text.dart';

class AdminChannels extends StatefulWidget {
  const AdminChannels({super.key});

  @override
  State<AdminChannels> createState() => _AdminChannelsState();
}

class _AdminChannelsState extends State<AdminChannels> {
  List<dynamic> _channels = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ByBugChannel.listChannels();
    if (result[0] == 1 && mounted) {
      setState(() {
        _channels = result[1];
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _togglePremium(Map channel) async {
    final current = channel['is_premium'] == true;
    final result = await ByBugChannel.setChannelPremium(
      channelId: channel['id'].toString(),
      isPremium: !current,
    );
    if (result[0] == 1) {
      _load();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result[1]?.toString() ?? 'Failed to update')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _channels.isEmpty
                ? const Center(child: Text('No channels yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _channels.length,
                    itemBuilder: (context, index) {
                      final channel = Map<String, dynamic>.from(_channels[index]);
                      final isPremium = channel['is_premium'] == true;
                      final name = (channel['name'] ?? '').toString();
                      final ownerId = (channel['owner_id'] ?? '').toString();

                      return Container(
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
                                  h1(name.isNotEmpty ? name : 'Unnamed channel'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Owner: $ownerId',
                                    style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isPremium ? 'Premium: Unlimited members' : 'Free: 50 member limit',
                                    style: TextStyle(
                                      color: isPremium ? Colors.amber : textColor.withOpacity(0.6),
                                      fontSize: 12,
                                      fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isPremium,
                              onChanged: (_) => _togglePremium(channel),
                              activeColor: Colors.amber,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
