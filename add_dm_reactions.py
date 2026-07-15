path = "lib/services/message.dart"
with open(path, "r") as f:
    content = f.read()

changed = False

# 1) Add "Add Reaction" menu item before "Delete Message" item
old_menu = """            CosmosMenu.item(
              "Delete Message",
              textColor: textColor,
              onTap: () async {
                await MessageServices.removeChatMessages(widget.value["chat_id"]);
                visible.value = false;
                visible.notifyListeners();
              },
            ),"""

new_menu = """            CosmosMenu.item(
              "Add Reaction",
              textColor: textColor,
              onTap: () {
                Navigator.of(context).pop();
                _showReactionPicker();
              },
            ),
            CosmosMenu.item(
              "Delete Message",
              textColor: textColor,
              onTap: () async {
                await MessageServices.removeChatMessages(widget.value["chat_id"]);
                visible.value = false;
                visible.notifyListeners();
              },
            ),"""

if old_menu in content:
    content = content.replace(old_menu, new_menu, 1)
    print("OK: Add Reaction menu item added")
    changed = True
else:
    print("WARNING: menu block not found exactly - checking alt spacing")

# 2) Add reaction functions + reactions row inside _MessageBlockState,
#    right after "ValueNotifier<bool> visible = ValueNotifier(true);"
old_field = "  ValueNotifier<bool> visible = ValueNotifier(true);"
new_field = old_field + """

  Future<void> _toggleReaction(String emoji) async {
    final messageId = widget.tag;
    final uid = MyProfileData.uid();

    final reactions = Map<String, dynamic>.from(widget.value['reactions'] ?? {});
    final users = List<dynamic>.from(reactions[emoji] ?? []);

    if (users.contains(uid)) {
      users.remove(uid);
    } else {
      users.add(uid);
    }

    if (users.isEmpty) {
      reactions.remove(emoji);
    } else {
      reactions[emoji] = users;
    }

    final updated = Map<String, dynamic>.from(widget.value);
    updated['reactions'] = reactions;
    await ByBugDatabase.update('message', messageId, updated);

    setState(() {
      widget.value['reactions'] = reactions;
    });
  }

  Future<void> _showReactionPicker() async {
    const emojis = [
      '👍', '❤️', '🔥', '😂', '😮', '😢', '🙏', '🎉', '💯', '🚀',
      '💎', '📈', '📉', '🤝', '👀', '💰', '⚡', '🐂', '🐻', '🌕',
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: emojis
              .map((e) => IconButton(
                    onPressed: () => Navigator.pop(ctx, e),
                    icon: Text(e, style: const TextStyle(fontSize: 26)),
                  ))
              .toList(),
        ),
      ),
    );
    if (selected != null) {
      await _toggleReaction(selected);
    }
  }

  Widget _buildReactions() {
    final reactions = Map<String, dynamic>.from(widget.value['reactions'] ?? {});
    if (reactions.isEmpty) return const SizedBox.shrink();
    final uid = MyProfileData.uid();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        children: reactions.entries.map((entry) {
          final emoji = entry.key;
          final users = List<dynamic>.from(entry.value);
          final reacted = users.contains(uid);
          return GestureDetector(
            onTap: () => _toggleReaction(emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: reacted ? Colors.amber.withOpacity(0.3) : Colors.black26,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: reacted ? Colors.amber : Colors.transparent,
                ),
              ),
              child: Text(
                '\$emoji \${users.length}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }"""

if old_field in content:
    content = content.replace(old_field, new_field, 1)
    print("OK: reaction functions added")
    changed = True
else:
    print("WARNING: field anchor not found - functions NOT added")

# 3) Insert reactions row below the message text, inside the Container
old_text_widget = """              child: Text(
                widget.value["text"],
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}"""

new_text_widget = """              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.value["text"],
                    style: TextStyle(color: Colors.white),
                  ),
                  _buildReactions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}"""

if old_text_widget in content:
    content = content.replace(old_text_widget, new_text_widget, 1)
    print("OK: reactions row wired into message bubble")
    changed = True
else:
    print("WARNING: text widget block not found exactly - reactions NOT wired into bubble UI, manual check needed")

if changed:
    with open(path, "w") as f:
        f.write(content)
    print("--- File saved ---")
else:
    print("--- No changes made ---")
