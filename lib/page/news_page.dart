import 'package:airdrop/services/admin.dart';
import 'package:airdrop/services/news.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
    News.getAll(context);
  }

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
                listenable: Listenable.merge([
                  MyProfileData.data,
                  News.newsListHome,
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
                                    h1("News"),
                                    Spacer(),

                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: News.newsListHome.value,
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
}
