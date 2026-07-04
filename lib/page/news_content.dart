import 'package:airdrop/services/admin.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/get_time.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/markdown.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class NewsContent extends StatelessWidget {
  final String tag;
  final String photo;
  final String name;
  final String details;
  final DateTime dateTime;
  const NewsContent({
    super.key,
    required this.tag,
    required this.photo,
    required this.name,
    required this.details,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            BottomPage(
              page: 3,
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
                                    h1("News"),
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
                                        SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(10),
                                          child: AirdroptourImage(
                                            photo,
                                            width: widthSizer(context),
                                            height: 250,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        h3(name),
                                        SizedBox(height: 6),
                                        Opacity(
                                          opacity: 0.5,
                                          child: p(getDateEN(dateTime)),
                                        ),
                                        SizedBox(height: 6),
                                        markdownText(details),
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
}
