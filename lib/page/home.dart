import 'dart:async';

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
import 'package:airdrop/page/notifications_page.dart';

ValueNotifier<List<Widget>> postsW = ValueNotifier([]);
PageController matchController = PageController();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<List<Widget>> pageDatas = ValueNotifier([]);

  static bool _isLoading = false;
  static DateTime? _lastLoadedAt;
  static const Duration _minReloadGap = Duration(seconds: 20);

  final ValueNotifier<int> _unreadCount = ValueNotifier(0);
  Timer? _notifTimer;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _loadUnreadCount();
    _notifTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _notifTimer?.cancel();
    _unreadCount.dispose();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final list = await ByBugInvite.getNotifications();
      final count = list.where((n) => n['read'] != true).length;
      if (!mounted) return;
      _unreadCount.value = count;
    } catch (_) {
      // sessizce yut, rozet güncellenmez
    }
  }

  Future<void> _loadHomeData({bool force = false}) async {
    if (_isLoading) return;
    if (!force &&
        _lastLoadedAt != null &&
        DateTime.now().difference(_lastLoadedAt!) < _minReloadGap) {
      return;
    }
    _isLoading = true;
    try {
      await Future.wait([
        MyProfileData.getMyProfile(),
        Post.getPosts(),
        AdminServices.getHomeCryptos(context),
        AdminServices.getAds(context),
        MessageServices.getDM(),
      ]);
      _lastLoadedAt = DateTime.now();
    } catch (_) {
    } finally {
      _isLoading = false;
    }
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
                              GestureDetector(
                                onTap: () async {
                                  await push(context, const NotificationsPage());
                                  _loadUnreadCount();
                                },
                                child: ValueListenableBuilder<int>(
                                  valueListenable: _unreadCount,
                                  builder: (context, count, child) {
                                    return Badge(
                                      isLabelVisible: count > 0,
                                      label: Text(count > 99 ? '99+' : '$count'),
                                      backgroundColor: Colors.redAccent,
                                      child: const Icon(
                                        Icons.notifications_none,
                                        size: 26,
                                      ),
                                    );
                                  },
                                ),
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
                    try {
                      final value = element["value"];
                      if (value == null) continue;
                      final data = value["data"] as Map<String, dynamic>? ?? {};
                      if (value["uid"] != MyProfileData.uid()) {
                        List<Widget> ccryp = [];
                        for (var cE in (data["cripto"] ?? [])) {
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
                            name: value["name"] ?? "",
                            bio: data["bio"] ?? "",
                            uid: value["uid"] ?? "",
                            photo: value["photo"] ?? "",
                            verify: data["verify"] ?? false,
                          ),
                        );
                      }
                    } catch (e) {
                      continue;
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
      ),    );
  }
}