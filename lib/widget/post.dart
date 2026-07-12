import 'package:airdrop/page/profile.dart';
import 'package:airdrop/page/youprofile.dart';
import 'package:airdrop/services/post.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/get_time.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class PostComponent extends StatelessWidget {
  final String photo;
  final String name;
  final DateTime dateTime;
  final String text;
  final String uid;
  final String tag;
  final bool verify;
  final bool isAdmin;
  const PostComponent({
    super.key,
    required this.photo,
    required this.name,
    required this.dateTime,
    required this.text,
    required this.uid,
    required this.tag,
    required this.verify,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: EdgeInsets.all(10),
      width: widthSizer(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: uid == MyProfileData.uid() ? navColor : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              if (uid == MyProfileData.uid()) {
                push(context, ProfilePage());
              } else {
                await YouProfileData.getMyProfile(uid);
                if (!context.mounted) return;
                push(context, YouProfilePage(uid: uid));
              }
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: AirdroptourImage(
                    photo.startsWith("http") ? photo : "assets/img/user.png",
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          bold(name, overflow: TextOverflow.ellipsis),
                          Visibility(
                            visible: verify,
                            child: Row(
                              children: [
                                SizedBox(width: 2),
                                Icon(
                                  Icons.verified,
                                  color: textColor,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                      p(
                        getDateEN(dateTime),
                        size: 10,
                        color: textColor.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6),
                Visibility(
                  visible: uid == MyProfileData.uid(),
                  child: CosmosMenu.builder(
                    context,
                    backgroundColor: navColor,
                    items: [
                      CosmosMenu.item(
                        "Delete Post",
                        textColor: textColor,
                        onTap: () async {
                          await Post.remove(tag);
                        },
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: textColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Row(children: [Expanded(child: p(text))]),
        SizedBox(height: 8),
        _PostReactionRow(tag: tag),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}


class _PostReactionRow extends StatefulWidget {
  final String tag;
  const _PostReactionRow({required this.tag});

  @override
  State<_PostReactionRow> createState() => _PostReactionRowState();
}

class _PostReactionRowState extends State<_PostReactionRow> {
  int likes = 0;
  int dislikes = 0;
  String? myReaction;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var data = await PostReactions.getReactionData(widget.tag);
    if (!mounted) return;
    setState(() {
      likes = data["likes"];
      dislikes = data["dislikes"];
      myReaction = data["myReaction"];
      loading = false;
    });
  }

  Future<void> _tap(String type) async {
    String? previous = myReaction;
    setState(() {
      if (previous == type) {
        myReaction = null;
        if (type == "like") likes--; else dislikes--;
      } else {
        if (previous == "like") likes--;
        if (previous == "dislike") dislikes--;
        if (type == "like") likes++; else dislikes++;
        myReaction = type;
      }
    });
    await PostReactions.toggleReaction(widget.tag, type);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _tap("like"),
          child: Row(
            children: [
              Icon(
                myReaction == "like" ? Icons.thumb_up : Icons.thumb_up_outlined,
                color: myReaction == "like" ? textColor : textColor.withOpacity(0.6),
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                "$likes",
                style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        GestureDetector(
          onTap: () => _tap("dislike"),
          child: Row(
            children: [
              Icon(
                myReaction == "dislike" ? Icons.thumb_down : Icons.thumb_down_outlined,
                color: myReaction == "dislike" ? textColor : textColor.withOpacity(0.6),
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                "$dislikes",
                style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
