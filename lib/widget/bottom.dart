import 'package:airdrop/page/channels_page.dart';
import 'package:airdrop/page/add_rain.dart';
import 'package:airdrop/page/explorer.dart';
import 'package:airdrop/page/home.dart';
import 'package:airdrop/page/news_page.dart';
import 'package:airdrop/page/profile.dart';
import 'package:airdrop/page/rain_content.dart';
import 'package:airdrop/page/rain_explorer.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class BottomPage extends StatelessWidget {
  final Widget child;
  final int page;
  const BottomPage({super.key, required this.child, required this.page});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            width: widthSizer(context),
            height: height(context),
          child: Padding(padding: const EdgeInsets.only(bottom: 70), child: child),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              gradient: LinearGradient(colors: [bg, navColor]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    push(context, HomePage());
                  },
                  child: Icon(
                    Icons.home,
                    color: page == 0 ? textColor : textColor.withOpacity(0.5),
                    size: 30,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    push(context, ExplorerPage());
                  },
                  child: Icon(
                    Icons.explore,
                    color: page == 1 ? textColor : textColor.withOpacity(0.5),
                    size: 30,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    push(context, ChannelsPage());
                  },
                  child: Icon(
                    Icons.campaign,
                    color: page == 2 ? textColor : textColor.withOpacity(0.5),
                    size: 30,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    push(context, NewsPage());
                  },
                  child: Icon(
                    Icons.newspaper,
                    color: page == 3 ? textColor : textColor.withOpacity(0.5),
                    size: 30,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    push(context, ProfilePage());
                  },
                  child: Icon(
                    Icons.person,
                    color: page == 4 ? textColor : textColor.withOpacity(0.5),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
