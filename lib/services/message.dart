import 'package:airdrop/page/messages/dm.dart';
import 'package:airdrop/page/messages/message_page.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class MessageServices extends ChangeNotifier {
  static ValueNotifier<String> chatInUid = ValueNotifier("");
  static ValueNotifier<String> chatInPhoto = ValueNotifier("");
  static ValueNotifier<String> chatInName = ValueNotifier("");
  static ValueNotifier<String> chatInChatID = ValueNotifier("");
  static ValueNotifier<DateTime> chatInCreateAT = ValueNotifier(DateTime.now());

  static Future<String> createChat(String targetUID) async {
    String tag = "chat_${CosmosRandom.randomTag()}";
    await ByBugDatabase.add("chat", tag, {
      "joiner": [targetUID, MyProfileData.uid()],
      "create_at": DateTime.now().toString(),
      "lastMessage": "Start of conversation!",
      "lastTime": DateTime.now().toString(),
      "photo": MyProfileData.photo(),
      "name": MyProfileData.name(),
    });
    return tag;
  }

  static Future<void> getDM() async {
    String bucket = "usersDatabaseByBugDatabase135153";
    var chats = await ByBugDatabase.getAll("chat");
    var usrs = await ByBugDatabase.getAll(bucket);
    dm.value.clear();
    String uu = "";
    for (var element in chats) {
      var value = element["value"];
      if (value["joiner"].contains(MyProfileData.uid())) {
        if (value["joiner"][0] == MyProfileData.uid()) {
          uu = value["joiner"][1];
        } else {
          uu = value["joiner"][0];
        }
        Map<String, dynamic> usr = {};
        for (var usrDatas in usrs) {
          if (usrDatas["value"]["uid"] == uu) {
            usr = usrDatas["value"];
            break;
          }
        }
        dm.value.add(
          DMItems(
            photo: usr["photo"],
            name: usr["name"],
            chatID: element["tag"],
            uid: uu,
            lastMessage: value["lastMessage"],
            dateTime: DateTime.parse(value["lastTime"]),
          ),
        );
      }
    }
    dm.notifyListeners();
  }

  static Future<String?> hasChatAvailable(String targetUID) async {
    var chats = await ByBugDatabase.getAll("chat");
    for (var element in chats) {
      if (element["value"]["joiner"].contains(targetUID) &&
          element["value"]["joiner"].contains(MyProfileData.uid())) {
        return element["tag"];
      }
    }
    return null;
  }

  static Future<void> remove(String targetUID) async {
    var chats = await ByBugDatabase.getAll("chat");
    String tag = "";
    for (var element in chats) {
      if (element["value"]["joiner"].contains(targetUID) &&
          element["value"]["joiner"].contains(MyProfileData.uid())) {
        tag = element["tag"];
      }
    }
    if (tag.isNotEmpty) {
      await ByBugDatabase.remove("chat", tag);
    }
  }

  static Future<void> addMessage(String chatID, String text) async {
    await ByBugDatabase.add(
      "message",
      "message_${CosmosRandom.randomTag() + CosmosRandom.string(5)}",
      {
        "text": text,
        "chat_id": chatID,
        "uid": MyProfileData.uid(),
        "create_at": DateTime.now().toString(),
      },
    );
    await ByBugDatabase.update("chat", chatInChatID.value, {
      "joiner": [chatInUid.value, MyProfileData.uid()],
      "create_at": chatInCreateAT.value.toString(),
      "lastMessage": text,
      "lastTime": DateTime.now().toString(),
      "photo": MyProfileData.photo(),
      "name": MyProfileData.name(),
    });
  }

  static Future<void> removeMessage(String tag) async {
    await ByBugDatabase.remove("message", tag);
  }

  static Future<void> removeChatMessages(String chatID) async {
    var allMessages = await ByBugDatabase.getAll("message");
    for (var element in allMessages) {
      if (element["value"]["chat_id"] == chatID) {
        await ByBugDatabase.remove("message", element["tag"]);
      }
    }
    messages.value.clear();
    messages.notifyListeners();
  }

  static Future<void> load(String chatID, BuildContext context) async {
    var chats = await ByBugDatabase.get("chat", chatID);
    if (chats["value"]["joiner"][0] == MyProfileData.uid()) {
      chatInUid.value = chats["value"]["joiner"][1];
    } else {
      chatInUid.value = chats["value"]["joiner"][0];
    }
    chatInUid.notifyListeners();
    String bucket = "usersDatabaseByBugDatabase135153";
    var userData = await ByBugDatabase.get(bucket, chatInUid.value);
    chatInName.value = userData["value"]["name"];
    chatInPhoto.value = userData["value"]["photo"];
    chatInChatID.value = chatID;
    chatInCreateAT.value = DateTime.parse(chats["value"]["create_at"]);
    var message = await ByBugDatabase.getAll("message");
    messages.value.clear();
    for (var element in message) {
      var value = element["value"];
      messages.value.add(
        MessageBlock(tag: element["tag"], value: element["value"]),
      );
    }

    messages.notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));

    if (!context.mounted) return;
    push(context, MessagePage(chatID: chatID, uid: chatInUid.value));
  }

  static listen(
    String chatID,
    Function(String tag, Map<String, dynamic> value) onMessage,
  ) {
    ByBugDatabase.listenAll(
      "message",
      onAdd: (tag, id, value) {
        if (value["chat_id"] == chatID) {
          onMessage(tag, value);
        }
      },
    );
  }

  static deleteListener() {
    ByBugDatabase.stopAllListeners();
  }
}

class MessageBlock extends StatefulWidget {
  final Map<String, dynamic> value;
  final String tag;
  const MessageBlock({super.key, required this.value, required this.tag});

  @override
  State<MessageBlock> createState() => _MessageBlockState();
}

class _MessageBlockState extends State<MessageBlock> {
  ValueNotifier<bool> visible = ValueNotifier(true);

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
  }
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([visible]),
      builder: (context, child) {
        return Visibility(
          visible: visible.value,
          child: CosmosMenu.builder(
            context,
            backgroundColor: navColor,
            items: [
              CosmosMenu.item(
                "Delete Message",
                textColor: textColor,
                onTap: () async {
                    await MessageServices.removeChatMessages(widget.value["chat_id"]);
                  visible.value = false;
                  visible.notifyListeners();
                },
              ),
            ],
            child: ChatBubble(
              clipper: ChatBubbleClipper3(
                type: widget.value["uid"] == MyProfileData.uid()
                    ? BubbleType.sendBubble
                    : BubbleType.receiverBubble,
              ),
              alignment: widget.value["uid"] == MyProfileData.uid()
                  ? Alignment.topRight
                  : null,
              margin: EdgeInsets.only(top: 20),
              backGroundColor: widget.value["uid"] == MyProfileData.uid()
                  ? defaultColor
                  : cColor,
              child: Container(
                constraints: BoxConstraints(
                  // ignore: use_build_context_synchronously
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Text(
                  widget.value["text"],
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
