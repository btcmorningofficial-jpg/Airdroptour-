import 'package:airdrop/page/add_rain.dart';
import 'package:airdrop/services/admin.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            BottomPage(
              page: 0,
              child: ListenableBuilder(
                listenable: Listenable.merge([]),
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
                                    h1("Contact Us"),
                                    Spacer(),

                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [h3("Communication")],
                                        ),
                                      ),
                                      _btn(
                                        Icons.alternate_email_rounded,
                                        "Email Address",
                                        () {
                                          openUrl(
                                            "mailto:airdroptour@gmail.com",
                                          );
                                        },
                                      ),
                                      _btn(Icons.link, "Instagram", () {
                                        openUrl(
                                          "https://www.instagram.com/airdroptour",
                                        );
                                      }),
                                      _btn(Icons.link, "X (Twitter)", () {
                                        openUrl("https://x.com/AirdropTour");
                                      }),
                                      _btn(Icons.link, "YouTube", () {
                                        openUrl(
                                          "https://youtube.com/@airdroptour",
                                        );
                                      }),
                                      _btn(Icons.link, "TikTok", () {
                                        openUrl(
                                          "https://www.tiktok.com/@airdroptour",
                                        );
                                      }),
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [h3("Support Us")],
                                        ),
                                      ),
                                      _btn(
                                        Icons.copy,
                                        "ETH Copy Our Address",
                                        () {
                                          copy(
                                            "0x949A77E0d491A328fA5CceA4b21147b136Ce3cCa",
                                          );
                                          getSuccessSnack(context, "Copied");
                                        },
                                      ),
                                      _btn(
                                        Icons.copy,
                                        "BNB Copy Our Address",
                                        () {
                                          copy(
                                            "0x949A77E0d491A328fA5CceA4b21147b136Ce3cCa",
                                          );
                                          getSuccessSnack(context, "Copied");
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(children: [h3("Join Us")]),
                                      ),
                                      _btn(Icons.groups, "Telegram", () {
                                        openUrl(
                                          "https://t.me/Airdroptourofficial",
                                        );
                                      }),
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(children: [h3("Join Us")]),
                                      ),
                                      _btn(
                                        Icons.radar_outlined,
                                        "Create Rain",
                                        () {
                                          push(context, AddRain());
                                        },
                                      ),
                                    ],
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

  Widget _btn(IconData icon, String text, Function() onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: navColor,
        ),
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: defaultColor),
            SizedBox(width: 4),
            Expanded(child: bold(text)),
            Icon(Icons.arrow_forward_ios, color: textColor),
          ],
        ),
      ),
    );
  }
}
