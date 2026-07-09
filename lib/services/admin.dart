import 'package:airdrop/page/profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/admin_user.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/markdown.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminServices extends ChangeNotifier {
  static String bucket = "usersDatabaseByBugDatabase135153";
  static ValueNotifier<List<Widget>> adminUserList = ValueNotifier([]);
  static ValueNotifier<List<Widget>> criptoList = ValueNotifier([]);
  static ValueNotifier<List<Widget>> adsAdmin = ValueNotifier([]);
  static ValueNotifier<List<String>> adsImgs = ValueNotifier([]);
  static ValueNotifier<Map<String, dynamic>> adsVal = ValueNotifier({});
  static ValueNotifier<List<Widget>> criptoHomeList = ValueNotifier([]);
  static ValueNotifier<List<Widget>> criptoExplorerList = ValueNotifier([]);

  static final ValueNotifier<List<Widget>> criptoExplorerListFiltered =
      ValueNotifier([]);
  static TextEditingController searchController = TextEditingController();

  static Future<void> getUsers() async {
    var usrs = await ByBugDatabase.getAll(bucket);
    adminUserList.value.clear();
    for (var element in usrs) {
      adminUserList.value.add(
        AdminUserComponent(
          isAdmin: element["value"]["data"]["isAdmin"] ?? false,
          verify: element["value"]["data"]["verify"] ?? false,
          status: element["value"]["data"]["status"] ?? "active",
          photo: element["value"]["photo"],
          name: element["value"]["name"],
          email: element["value"]["email"],
          uid: element["value"]["uid"],
        ),
      );
    }
    adminUserList.notifyListeners();
  }

  void filterExplorerList(String query) {
    final originalList = criptoExplorerList.value;

    final filtered = originalList.where((widget) {
      if (widget is Container && widget.child is Row) {
        final row = widget.child as Row;
        final Expanded? expanded =
            row.children.firstWhere((w) => w is Expanded) as Expanded?;

        if (expanded?.child is CryptoWidget) {
          final crypto = expanded!.child as CryptoWidget;
          final name = crypto.name.toLowerCase();
          final details = crypto.details.toLowerCase();
          return name.contains(query.toLowerCase()) ||
              details.contains(query.toLowerCase());
        }
      }
      return false;
    }).toList();

    criptoExplorerListFiltered.value = filtered;
  }

  static Future<void> addCriptoDB(
    String image,
    String name,
    String details,
    String website,
  ) async {
    await ByBugDatabase.add("crypto", CosmosRandom.randomTag(), {
      "image": image,
      "details": details,
      "name": name,
      "website": website,
      "uid": MyProfileData.uid(),
      "create_at": DateTime.now().toString(),
    });
  }

  static Future<void> addAdsSystem(
    String image,
    String name,
    String details,
  ) async {
    await ByBugDatabase.add("ads", CosmosRandom.randomTag(), {
      "image": image,
      "details": details,
      "name": name,
      "uid": MyProfileData.uid(),
      "create_at": DateTime.now().toString(),
    });
  }

  static Future<void> getAdsAdmin(BuildContext context) async {
    var ads = await ByBugDatabase.getAll("ads");
    List<Widget> tempAds = [];

    for (var element in ads) {
      Map<String, dynamic> val = element["value"];

      tempAds.add(
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.only(
                  topLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: AirdroptourImage(
                  val["image"].startsWith("http")
                      ? val["image"]
                      : "assets/img/soru.png",
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bold(val["name"]),
                    p(val["details"], overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await ByBugDatabase.remove("ads", element["tag"]);
                  if (!context.mounted) return;
                  getSuccessSnack(context, "Banner Yayından Kaldırıldı.");
                  adsAdmin.value = tempAds;
                  adsAdmin.notifyListeners();
                  await Future.delayed(Durations.long2);
                  if (!context.mounted) return;
                  await getAdsAdmin(context);
                },
                child: Icon(Icons.delete_forever, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }
    adsAdmin.value = tempAds;
    adsAdmin.notifyListeners();
  }

  static Future<void> getAds(BuildContext context) async {
    var ads = await ByBugDatabase.getAll("ads");
    List<String> tempAds = [];
    Map<String, dynamic> adsMap = {};

    for (var element in ads) {
      Map<String, dynamic> val = element["value"];

      tempAds.add(val["image"]);
      adsMap.addAll({element["tag"]: val});
    }
    adsVal.value = adsMap;
    adsImgs.value = tempAds;
    adsImgs.notifyListeners();
    adsVal.notifyListeners();
  }

  static Map<String, dynamic>? getValuesAds(String image) {
    for (var element in adsVal.value.keys) {
      if (adsVal.value[element]["image"] == image) {
        return adsVal.value[element];
      }
    }
    return null;
  }

  static Future<void> getCryptos(BuildContext context) async {
    var crypto = await ByBugDatabase.getAll("crypto");
    List<Widget> tempCrypto = [];

    for (var element in crypto) {
      Map<String, dynamic> val = element["value"];

      tempCrypto.add(
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.only(
                  topLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: AirdroptourImage(
                  val["image"].startsWith("http")
                      ? val["image"]
                      : "assets/img/soru.png",
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bold(val["name"]),
                    p(val["details"], overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await ByBugDatabase.remove("crypto", element["tag"]);
                  if (!context.mounted) return;
                  getSuccessSnack(context, "Crypto has been taken down.");
                  criptoList.value = tempCrypto;
                  criptoList.notifyListeners();
                  await Future.delayed(Durations.long2);
                  if (!context.mounted) return;
                  await getCryptos(context);
                },
                child: Icon(Icons.delete_forever, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }
    criptoList.value = tempCrypto;
    criptoList.notifyListeners();
  }

  static List<String> cryptosNames = [];
  static Future<void> getHomeCryptos(BuildContext context) async {
    var crypto = await ByBugDatabase.getAll("crypto");
    cryptosNames.clear();
    List<Widget> tempCrypto = [];
    List<Widget> tempCryptoExplorer = [];

    for (var element in crypto) {
      Map<String, dynamic> val = element["value"];
      cryptosNames.add(val["image"]);
      if (AdminServices.cryptosNames.contains(val["image"])) {
        tempCrypto.add(
          CryptoWidget(
            id: element["tag"],
            photo: val["image"],
            name: val["name"],
            details: val["details"],
            website: val["website"],
          ),
        );
      }

      if (AdminServices.cryptosNames.contains(val["image"])) {
        tempCryptoExplorer.add(
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage("assets/2151546140.jpg"),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CryptoWidget(
                    id: element["tag"],
                    photo: val["image"],
                    name: val["name"],
                    details: val["details"],
                    website: val["website"],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: textColor),
                SizedBox(width: 8),
              ],
            ),
          ),
        );
      }
    }
    criptoHomeList.value = tempCrypto;
    criptoHomeList.notifyListeners();
    criptoExplorerList.value = tempCryptoExplorer;
    criptoExplorerList.notifyListeners();
    criptoExplorerListFiltered.value = tempCryptoExplorer;
  }

  static void addCripto(BuildContext context) async {
    ValueNotifier<String> imgCripto = ValueNotifier("");
    TextEditingController varlikName = TextEditingController();
    TextEditingController varlikDetails = TextEditingController();
    TextEditingController varlikWebsite = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListenableBuilder(
            listenable: Listenable.merge([imgCripto]),
            builder: (context, child) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => pop(context),
                    child: Container(
                      width: width(context),
                      height: height(context),
                      color: Colors.transparent,
                    ),
                  ),
                  Center(
                    child: Container(
                      height: height(context) * 0.8,
                      padding: EdgeInsets.all(8),
                      width: widthSizer(context) * 0.9,
                      decoration: BoxDecoration(
                        color: navColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            h3("Crypto Assets", color: defaultColor),
                            p("Add New Crypto Asset"),
                            SizedBox(height: 30),
                            GestureDetector(
                              onTap: () async {
                                String? imgSource = await pickImage();
                                if (imgSource == null) return;
                                String? imgUrl = await ByBugStorage.uploadFile(
                                  imgSource,
                                );
                                if (imgUrl == null) return;
                                imgCripto.value = imgUrl;
                                imgCripto.notifyListeners();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.only(
                                  topLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                child: AirdroptourImage(
                                  imgCripto.value.startsWith("http")
                                      ? imgCripto.value
                                      : "assets/img/add.png",
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            textfield(
                              text: "Crypto Asset Name",
                              textController: varlikName,
                              keyboardType: TextInputType.name,
                              maxLines: 1,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(120),
                              ],
                            ),
                            textfield(
                              text: "Crypto Asset Details",
                              textController: varlikDetails,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1200),
                              ],
                            ),
                            textfield(
                              text: "Official Website (https://...)",
                              textController: varlikWebsite,
                              keyboardType: TextInputType.url,
                              maxLines: 1,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(300),
                              ],
                            ),

                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                await addCriptoDB(
                                  imgCripto.value,
                                  varlikName.text,
                                  varlikDetails.text,
                                  varlikWebsite.text,
                                );
                                if (!context.mounted) return;
                                pop(context);
                                getSuccessSnack(context, "Crypto Asset Added");
                                await getCryptos(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                width: widthSizer(context),
                                decoration: BoxDecoration(
                                  color: defaultColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(child: h5("Publish")),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static void addAds(BuildContext context) async {
    ValueNotifier<String> imgCripto = ValueNotifier("");
    TextEditingController varlikName = TextEditingController();
    TextEditingController varlikDetails = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListenableBuilder(
            listenable: Listenable.merge([imgCripto]),
            builder: (context, child) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => pop(context),
                    child: Container(
                      width: width(context),
                      height: height(context),
                      color: Colors.transparent,
                    ),
                  ),
                  Center(
                    child: Container(
                      height: height(context) * 0.8,
                      padding: EdgeInsets.all(8),
                      width: widthSizer(context) * 0.9,
                      decoration: BoxDecoration(
                        color: navColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            h3("Banners", color: defaultColor),
                            p("Add New Banner"),
                            SizedBox(height: 30),
                            GestureDetector(
                              onTap: () async {
                                String? imgSource = await pickImage();
                                if (imgSource == null) return;
                                String? imgUrl = await ByBugStorage.uploadFile(
                                  imgSource,
                                );
                                if (imgUrl == null) return;
                                imgCripto.value = imgUrl;
                                imgCripto.notifyListeners();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.only(
                                  topLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                child: AirdroptourImage(
                                  imgCripto.value.startsWith("http")
                                      ? imgCripto.value
                                      : "assets/img/add.png",
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            textfield(
                              text: "Crypto Asset Name",
                              textController: varlikName,
                              keyboardType: TextInputType.name,
                              maxLines: 1,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(120),
                              ],
                            ),
                            textfield(
                              text: "Crypto Asset Details",
                              textController: varlikDetails,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1200),
                              ],
                            ),

                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                await addAdsSystem(
                                  imgCripto.value,
                                  varlikName.text,
                                  varlikDetails.text,
                                );
                                if (!context.mounted) return;
                                pop(context);
                                getSuccessSnack(context, "Banner Added");
                                await getAdsAdmin(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                width: widthSizer(context),
                                decoration: BoxDecoration(
                                  color: defaultColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(child: h5("Publish")),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class CryptoWidget extends StatelessWidget {
  final String id;
  final String photo;
  final String name;
  final String details;
  final String? website;
  final bool? readOnly;
  const CryptoWidget({
    super.key,
    required this.id,
    required this.photo,
    required this.name,
    required this.details,
    this.website,
    this.readOnly,
  });

  static const Map<String, String> exchangeLinks = {
    "LBank": "https://www.lbkpro.net/ref/F694",
    "Binance":
        "https://www.binance.com/activity/referral-entry/CPA?ref=CPA_00V117EBZL",
    "MEXC": "https://promote.mexc.com/r/gJvZH1E5tf",
    "Gate.io":
        "https://www.gate.com/referral/earn-together/invite/UlFDVwpZ?ref=UlFDVwpZ&ref_type=103&utm_cmp=rXJBDjtJ&activity_id=1781161013843",
    "KuCoin":
        "https://www.kucoin.com/ucenter/signup?rcode=CX87A4A7&utm_source=app_g_Share",
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
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
                  Center(
                    child: Container(
                      height: height(context) * 0.5,
                      padding: EdgeInsets.all(8),
                      width: widthSizer(context) * 0.9,
                      decoration: BoxDecoration(
                        color: navColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          h5(name),
                          Expanded(child: markdownText(details)),

                          if (website != null && website!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () async {
                                  final uri = Uri.tryParse(website!);
                                  if (uri != null) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  width: widthSizer(context),
                                  decoration: BoxDecoration(
                                    color: cColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: h5("Visit Official Website"),
                                  ),
                                ),
                              ),
                            ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: CryptoWidget.exchangeLinks.entries.map(
                              (entry) {
                                return GestureDetector(
                                  onTap: () async {
                                    final uri = Uri.tryParse(entry.value);
                                    if (uri != null) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: defaultColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: h5(entry.key),
                                  ),
                                );
                              },
                            ).toList(),
                          ),

                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              if (MyProfileData.hasFavorite(name)) {
                                MyProfileData.removeFavorite(name);
                              } else {
                                await MyProfileData.addFavorite(
                                  photo,
                                  details,
                                  name,
                                );
                              }

                              if (!context.mounted) return;
                              pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              width: widthSizer(context),
                              decoration: BoxDecoration(
                                color: MyProfileData.hasFavorite(name)
                                    ? Colors.red
                                    : defaultColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: h5(
                                  MyProfileData.hasFavorite(name)
                                      ? "Remove from Favorites"
                                      : "Add to Favorites",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              width: widthSizer(context),
                              decoration: BoxDecoration(
                                color: cColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(child: h5("Close")),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                SizedBox(width: 50),
                Expanded(
                  child: h3(
                    name,
                    fontWeight: FontWeight.normal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    size: 18,
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: AirdroptourImage(
                    photo.startsWith("http") ? photo : "assets/img/soru.png",
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
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