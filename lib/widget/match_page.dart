import 'dart:async';
import 'package:airdrop/page/home.dart';
import 'package:airdrop/page/youprofile.dart';
import 'package:airdrop/services/message.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class MatchPage extends StatefulWidget {
  final String name;
  final String bio;
  final String uid;
  final String photo;
  final List<Widget> matchCrypto;
  const MatchPage({
    super.key,
    required this.name,
    required this.bio,
    required this.uid,
    required this.photo,
    required this.matchCrypto,
  });

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  ValueNotifier<bool> turn = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    Timer.periodic(Durations.extralong4, (timer) {
      turn.value = !turn.value;
      turn.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg.withOpacity(0.6),
      body: Center(
        child: SizedBox(
          width: widthSizer(context),
          child: ListenableBuilder(
            listenable: Listenable.merge([turn]),
            builder: (context, child) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),

                    Row(
                      children: [
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            matchController.previousPage(
                              duration: Durations.medium1,
                              curve: Curves.linear,
                            );
                          },
                          child: AnimatedOpacity(
                            duration: Durations.medium4,
                            opacity: turn.value ? 1 : 0.2,
                            child: Icon(
                              Icons.arrow_back,
                              color: textColor.withOpacity(0.5),
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    AirdroptourImage("assets/5Mz4.gif", width: 80, height: 80),
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: navColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      width: widthSizer(context),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await YouProfileData.getMyProfile(widget.uid);
                              if (!context.mounted) return;
                              push(context, YouProfilePage(uid: widget.uid));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadiusGeometry.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              child: AirdroptourImage(
                                widget.photo.startsWith("http")
                                    ? widget.photo
                                    : "assets/img/user.png",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          h3(widget.name),
                          p(
                            widget.bio,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CosmosScroller(
                                  scrollDirection: Axis.horizontal,
                                  children: widget.matchCrypto,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var has =
                                      await MessageServices.hasChatAvailable(
                                        widget.uid,
                                      );
                                  if (has == null) {
                                    var tag = await MessageServices.createChat(
                                      widget.uid,
                                    );
                                    if (!context.mounted) return;
                                    await MessageServices.load(tag, context);
                                  } else {
                                    if (!context.mounted) return;
                                    await MessageServices.load(has, context);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: textColor.withOpacity(0.1),
                                  ),
                                  child: Icon(
                                    Icons.messenger_rounded,
                                    color: textColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  getSuccessSnack(
                                    context,
                                    "Complaint Submitted.",
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: textColor.withOpacity(0.1),
                                  ),
                                  child: Icon(
                                    Icons.warning,
                                    color: textColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    p("Chat with the user or swipe!"),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            matchController.nextPage(
                              duration: Durations.medium1,
                              curve: Curves.linear,
                            );
                          },
                          child: AnimatedOpacity(
                            duration: Durations.medium4,
                            opacity: turn.value ? 1 : 0.2,
                            child: Icon(
                              Icons.arrow_forward,
                              color: textColor.withOpacity(0.5),
                              size: 50,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
