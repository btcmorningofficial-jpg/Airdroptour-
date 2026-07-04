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
  const PostComponent({
    super.key,
    required this.photo,
    required this.name,
    required this.dateTime,
    required this.text,
    required this.uid,
    required this.tag,
    required this.verify,
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
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
