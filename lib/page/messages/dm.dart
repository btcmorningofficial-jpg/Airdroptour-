import 'package:airdrop/page/home.dart';
import 'package:airdrop/services/message.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/get_time.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

ValueNotifier<List<Widget>> dm = ValueNotifier([]);

class DMBox extends StatefulWidget {
  const DMBox({super.key});

  @override
  State<DMBox> createState() => _DMBoxState();
}

class _DMBoxState extends State<DMBox> {
  @override
  void initState() {
    super.initState();
    MessageServices.getDM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: ListenableBuilder(
        listenable: Listenable.merge([dm]),
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios_new),
                      ),

                      Spacer(),

                      h1("Message Box"),
                      SizedBox(width: 4),
                      Container(
                        width: 5,
                        height: 25,
                        decoration: BoxDecoration(
                          color: defaultColor,
                          borderRadius: BorderRadius.circular(1020),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: dm.value),
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

class DMItems extends StatelessWidget {
  final String photo;
  final String name;
  final String chatID;
  final String lastMessage;
  final DateTime dateTime;

  const DMItems({
    super.key,
    required this.photo,
    required this.name,
    required this.chatID,
    required this.lastMessage,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await MessageServices.load(chatID, context);
      },
      child: Container(
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
                  p(lastMessage, overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
