import 'package:flutter/material.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/theme/color.dart';

class ChannelSettingsPage extends StatefulWidget {
  final Map<String, dynamic> channel;

  const ChannelSettingsPage({super.key, required this.channel});

  @override
  State<ChannelSettingsPage> createState() => _ChannelSettingsPageState();
}

class _ChannelSettingsPageState extends State<ChannelSettingsPage> {
  late final _nameController = TextEditingController(text: widget.channel['name'] ?? '');
  late final _descController = TextEditingController(text: widget.channel['description'] ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kanal adi bos olamaz')),
      );
      return;
    }

    setState(() => _saving = true);

    final result = await ByBugChannel.updateChannel(
      channelId: widget.channel['id'],
      name: name,
      description: _descController.text.trim(),
    );

    setState(() => _saving = false);

    if (result[0] == 1) {
      if (mounted) Navigator.pop(context, result[1]);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result[1]?.toString() ?? 'Update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Kanal Ayarlari'),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kanal Adi', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: navColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: navColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
