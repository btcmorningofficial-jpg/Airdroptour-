import re

path = "lib/page/channel_detail_page.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

old = """IconButton(
        icon: const Icon(Icons.person_add_alt, color: Colors.white),
        tooltip: 'Invite',
        onPressed: _shareInviteLink,
      ),
      IconButton(
        icon: const Icon(Icons.group_add, color: Colors.white),
        tooltip: 'Invite Members',
        onPressed: () async {
          final sent = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChannelInvitePage(channelId: widget.channel['id']),
            ),
          );
          if (sent == true && mounted) {
            _loadMembers();
          }
        },
      ),"""

new = """PopupMenuButton<String>(
        icon: const Icon(Icons.person_add_alt, color: Colors.white),
        tooltip: 'Invite',
        onSelected: (value) async {
          if (value == 'invite_link') {
            _shareInviteLink();
          } else if (value == 'invite_members') {
            final sent = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChannelInvitePage(channelId: widget.channel['id']),
              ),
            );
            if (sent == true && mounted) {
              _loadMembers();
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'invite_link',
            child: Row(
              children: [
                Icon(Icons.link, size: 20),
                SizedBox(width: 8),
                Text('Share Invite Link'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'invite_members',
            child: Row(
              children: [
                Icon(Icons.group_add, size: 20),
                SizedBox(width: 8),
                Text('Invite Members'),
              ],
            ),
          ),
        ],
      ),"""

if old not in content:
    print("UYARI: eski blok tam olarak eşleşmedi. Boşluk/indent farkı olabilir. Elle kontrol et.")
else:
    content = content.replace(old, new)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Patch başarıyla uygulandı.")
