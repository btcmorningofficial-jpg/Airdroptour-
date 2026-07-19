import 'package:airdrop/page/edit.dart';
import 'package:airdrop/page/login.dart';
import 'package:airdrop/services/admin.dart';
import 'package:airdrop/services/post.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/auto_scroll_crypto_row.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';

TextEditingController postControllerYou = TextEditingController();
ValueNotifier<List<Widget>> profilePostsYou = ValueNotifier([]);

class YouProfilePage extends StatefulWidget {
  final String uid;
  const YouProfilePage({super.key, required this.uid});

  @override
  State<YouProfilePage> createState() => _YouProfilePageState();
}

class _YouProfilePageState extends State<YouProfilePage> {
  ValueNotifier<bool> bioLong = ValueNotifier(false);
  List<List<String>> social = [];
  List<String> socialText = [];
  ValueNotifier<List<Widget>> profileCrypto = ValueNotifier([]);
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await YouProfileData.getMyProfile(widget.uid);
      if (!mounted) return;
      await AdminServices.getHomeCryptos(context);
      profileCrypto.value.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "DEBUG: cripto=${YouProfileData.cripto().length} cryptosNames=${AdminServices.cryptosNames.length}",
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
    for (var element in YouProfileData.cripto()) {
        if (AdminServices.cryptosNames.contains(element["image"])) {
          profileCrypto.value.add(
            CryptoWidget(
              readOnly: true,
              id: "id",
              photo: element["image"],
              name: element["name"],
              details: element["details"],
            ),
          );
        }
      }
      profileCrypto.notifyListeners();
      var socialData = YouProfileData.social();

      social.clear();
      for (var element in socialData.keys) {
        Map<String, dynamic> value = socialData[element];
        social.add([value["name"], value["url"]]);
        socialText.add(value["name"]);
      }
      Post.getProfileYouPosts(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: BottomPage(
          page: 1,
          child: ListenableBuilder(
            listenable: Listenable.merge([
              bioLong,
              YouProfileData.data,
              profilePostsYou,
              profileCrypto,
            ]),
            builder: (context, child) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: defaultColor,
                                      borderRadius: BorderRadius.circular(1020),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  h1("My Profile"),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadiusGeometry.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                    child: AirdroptourImage(
                                      YouProfileData.photo().startsWith("http")
                                          ? YouProfileData.photo()
                                          : "assets/img/user.png",
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Visibility(
                                              visible: YouProfileData.premium(),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.verified,
                                                    color: textColor,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 4),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: h3(
                                                YouProfileData.name(),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: textColor,
                                              size: 12,
                                            ),
                                            Expanded(
                                              child: subP(
                                                YouProfileData.isAdmin()
                                                    ? "Admin/Developer Account"
                                                    : "User Account",
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    children: [
                                      h3(
                                        profilePostsYou.value.length.toString(),
                                        color: defaultColor,
                                      ),
                                      subP(
                                        "Post",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntrinsicWidth(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await SelectDialog.showModal<String>(
                                          context,
                                          searchHint:
                                              "Search in Social Media...",
                                          label: "Social Media",
                                          backgroundColor: navColor,
                                          constraints: BoxConstraints(
                                            maxWidth: width(context) * 0.5,
                                          ),
                                          items: socialText,
                                          onChange: (p0) async {
                                            for (var element in social) {
                                              if (element[0] == p0) {
                                                await openUrl(element[1]);
                                                break;
                                              }
                                            }
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            1020,
                                          ),
                                          color: defaultColor,
                                        ),
                                        child: Row(
                                          children: [
                                            AirdroptourImage(
                                              "assets/icon/Star Animation.gif",
                                              width: 16,
                                              height: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: subP(
                                                "Social Media",
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () {
                                      bioLong.value = !bioLong.value;
                                      bioLong.notifyListeners();
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: p(
                                            YouProfileData.bio(),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: YouProfileData.bio().length > 100,
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: subP(
                                        bioLong.value
                                            ? "Make the text smaller."
                                            : "Read more",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: h3("•", color: textColor.withOpacity(0.5)),
                            ),
                            AutoScrollCryptoRow(
          children: profileCrypto.value,
        ),
                            Column(children: profilePostsYou.value),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
