import 'package:airdrop/page/home.dart';
import 'package:airdrop/page/youprofile.dart';
import 'package:airdrop/services/message.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/tools/get_time.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

ValueNotifier<List<Widget>> messages = ValueNotifier([]);
ScrollController scrollController = ScrollController();

class MessagePage extends StatefulWidget {
  final String chatID;
  final String uid;
  const MessagePage({super.key, required this.chatID, required this.uid});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Durations.medium1, () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    MessageServices.listen(widget.chatID, (tag, value) async {
      messages.value.add(MessageBlock(value: value, tag: tag));
      messages.notifyListeners();
      await Future.delayed(Duration(milliseconds: 100));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Durations.medium1,
        curve: Curves.linear,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    MessageServices.deleteListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: ListenableBuilder(
        listenable: Listenable.merge([messages]),
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios_new),
                      ),
                      GestureDetector(
                onTap: () async {
                  try {
                    await YouProfileData.getMyProfile(widget.uid);
                    if (!context.mounted) return;
                    push(context, YouProfilePage(uid: widget.uid));
                  } catch (e) {
                    if (!context.mounted) return;
                    getSuccessSnack(context, "Profil acilamadi: $e");
                  }
                },
                child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              child: AirdroptourImage(
                                MessageServices.chatInPhoto.value.startsWith(
                                      "http",
                                    )
                                    ? MessageServices.chatInPhoto.value
                                    : "assets/img/user.png",
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 4),

                            bold(MessageServices.chatInName.value),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_back_ios_new, color: Colors.transparent),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          Column(children: messages.value),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: textfield(
                          textController: controller,
                          text: "Write a message...",
                          nonMargin: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          String txt = controller.text;
                          controller.clear();
                          await MessageServices.addMessage(widget.chatID, txt);
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: navColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(Icons.send_rounded, color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DMItem extends StatelessWidget {
  final String photo;
  final String name;
  final String chatID;
  final String lastMessage;
  final DateTime dateTime;

  const DMItem({
    super.key,
    required this.photo,
    required this.name,
    required this.chatID,
    required this.lastMessage,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: navColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          ClipOval(
            child: AirdroptourImage(
              photo.startsWith("http") ? photo : "assets/img/user.png",
              width: 60,
              height: 60,
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: h5(name)),
                    Opacity(
                      opacity: 0.7,
                      child: subP(
                        "${getDateEN(dateTime).split(",")[1].trim()}, ${getDateEN(dateTime).split(",")[2].trim()}",
                      ),
                    ),
                  ],
                ),
                p(lastMessage, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
