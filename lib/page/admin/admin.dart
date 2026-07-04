import 'package:airdrop/page/admin/ads.dart';
import 'package:airdrop/page/admin/criptos.dart';
import 'package:airdrop/page/admin/news.dart';
import 'package:airdrop/page/admin/rains.dart';
import 'package:airdrop/page/admin/users.dart';
import 'package:airdrop/services/post.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:flutter/material.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  ValueNotifier<bool> bioLong = ValueNotifier(false);
  PageController pageController = PageController();
  List<List<String>> social = [];
  List<String> socialText = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: BottomPage(
          page: 0,
          child: ListenableBuilder(
            listenable: Listenable.merge([bioLong, MyProfileData.data]),
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
                                    borderRadius: BorderRadius.circular(1020),
                                  ),
                                ),
                                SizedBox(width: 4),
                                h1("Admin Panel"),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        pageController.jumpToPage(0);
                                      },
                                      child: Icon(
                                        Icons.group_outlined,
                                        color: textColor,
                                        size: 30,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        pageController.jumpToPage(1);
                                      },
                                      child: Icon(
                                        Icons.monetization_on_outlined,
                                        color: textColor,
                                        size: 30,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        pageController.jumpToPage(2);
                                      },
                                      child: Icon(
                                        Icons.newspaper,
                                        color: textColor,
                                        size: 30,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        pageController.jumpToPage(3);
                                      },
                                      child: Icon(
                                        Icons.fluorescent_outlined,
                                        color: textColor,
                                        size: 30,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        pageController.jumpToPage(4);
                                      },
                                      child: Icon(
                                        Icons.ads_click,
                                        color: textColor,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: PageView(
                              physics: NeverScrollableScrollPhysics(),
                              controller: pageController,
                              children: [
                                AdminUsers(),
                                CriptoAdmin(),
                                NewsAdmin(),
                                AdminRains(),
                                AdminADS(),
                              ],
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
      ),
    );
  }
}
