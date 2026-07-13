import 'package:flutter/material.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/text.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _creating = false;
  String? _error;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Channel created successfully')),
        );
      }
    } else {
      setState(() => _error = result[1]?.toString() ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: h1('Channels'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            h3('My channels'),
            const SizedBox(height: 10),
            const Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
