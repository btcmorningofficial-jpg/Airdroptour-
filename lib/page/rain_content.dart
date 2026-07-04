import 'package:airdrop/services/admin.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/markdown.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class RainContent extends StatelessWidget {
  final String award;
  final String name;
  final String about;
  final String uid;
  final String status;
  final List<Widget> missions;
  final String tag;
  const RainContent({
    super.key,
    required this.award,
    required this.name,
    required this.about,
    required this.uid,
    required this.status,
    required this.tag,
    required this.missions,
  });

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            BottomPage(
              page: 2,
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  MyProfileData.data,
                  AdminServices.criptoExplorerList,
                ]),
                builder: (context, child) {
                  return SafeArea(
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
                                        borderRadius: BorderRadius.circular(
                                          1020,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    h1("Rain"),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () => pop(context),
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(),
                                        SizedBox(height: 10),
                                        h3(name, color: defaultColor),
                                        SizedBox(height: 6),
                                        Opacity(
                                          opacity: 0.5,
                                          child: _buildUserData(
                                            Icons.card_giftcard,
                                            "Award",
                                            award,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        markdownText(about),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            h3(
                                              "•",
                                              color: textColor.withOpacity(0.5),
                                            ),
                                          ],
                                        ),
                                        Column(children: missions),
                                      ],
                                    ),
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  Row _buildUserData(IconData icon, String tag, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: defaultColor),
        SizedBox(width: 4),
        bold("$tag: "),
        Expanded(child: p(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
