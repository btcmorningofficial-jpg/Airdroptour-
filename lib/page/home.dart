import 'package:airdrop/page/rain_explorer.dart';
import 'package:airdrop/page/messages/dm.dart';
import 'package:airdrop/page/profile.dart';
import 'package:airdrop/services/admin.dart';
import 'package:airdrop/services/message.dart';
import 'package:airdrop/services/post.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/auto_scroll_crypto_row.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/match_crypto_chip.dart';
import 'package:airdrop/widget/match_page.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/slider.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

ValueNotifier<List<Widget>> postsW = ValueNotifier([]);
PageController matchController = PageController();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<List<Widget>> pageDatas = ValueNotifier([]);
  @override
  void initState() {
    super.initState();
    MyProfileData.getMyProfile();
    Post.getPosts();
    AdminServices.getHomeCryptos(context);
    AdminServices.getAds(context);
    MessageServices.getDM();
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
                  postsW,
                  AdminServices.criptoHomeList,
                  AdminServices.adsImgs,
                  AdminServices.adsVal,
                ]),
                builder: (context, child) {
                  return SafeArea(
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
                              h1("Airdroptour"),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  addPost(context);
                                },
                                child: Icon(Icons.add_box_outlined, size: 28),
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  push(context, RainExplorerPage());
                                },
                                child: Icon(Icons.whatshot, size: 26),
                              ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      push(context, DMBox());
                    },
                    child: Icon(Icons.messenger_outline, size: 26),
                  ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      AirdroptourSlider.classic(
                                        AdminServices.adsImgs.value,
                                      ),
                                      SizedBox(height: 30),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AutoScrollCryptoRow(
                                              children: AdminServices
                                                  .criptoHomeList
                                                  .value,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 30),
                                      Column(children: postsW.value),
                                      SizedBox(height: 120),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: 100,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  loading(context);
                  String bucket = "usersDatabaseByBugDatabase135153";
                  pageDatas.value.clear();
                  var usrs = await ByBugDatabase.getAll(bucket);
                  for (var element in usrs) {
                    if (element["value"]["uid"] != MyProfileData.uid()) {
                      List<Widget> ccryp = [];
                      for (var cE
                          in (element["value"]["data"]["cripto"] ?? [])) {
                        if (AdminServices.cryptosNames.contains(cE["image"])) {
                          ccryp.add(
                            MatchCryptoChip(
                              photo: cE["image"],
                              name: cE["name"],
                              details: cE["details"] ?? "",
                            ),
                          );
                        }
                      }
                      pageDatas.value.add(
                        MatchPage(
                          matchCrypto: ccryp,
                          name: element["value"]["name"],
                          bio: element["value"]["data"]["bio"],
                          uid: element["value"]["uid"],
                          photo: element["value"]["photo"],
            verify: element["value"]["data"]["verify"] ?? false,
                        ),
                      );
                    }
                  }
                  pageDatas.value.shuffle();
                  pageDatas.notifyListeners();
                  if (!context.mounted) return;
                  pop(context);

                  showDialog(
                    context: context,
                    useSafeArea: false,
                    builder: (context) {
                      return Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => pop(context),
                              child: Container(
                                width: width(context),
                                height: height(context),
                                color: Colors.transparent,
                              ),
                            ),
                            PageView(
                              scrollDirection: Axis.horizontal,
                              controller: matchController,
                              children: pageDatas.value,
                            ),
                            Positioned(
                              top: 20,
                              right: 20,
                              child: GestureDetector(
                                onTap: () {
                                  pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: textColor,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: IntrinsicWidth(
                  child: IntrinsicHeight(
                    child: Container(
                      padding: EdgeInsets.only(left: 2, bottom: 2, top: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.amber],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AirdroptourImage(
                              "assets/5Mz4.gif",
                              width: 40,
                              height: 40,
                            ),
                            bold("Match!"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
