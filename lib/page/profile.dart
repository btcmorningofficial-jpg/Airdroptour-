import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/page/add_rain.dart';
import 'package:airdrop/page/admin/admin.dart';
import 'package:airdrop/page/contact.dart';
import 'package:airdrop/page/edit.dart';
import 'package:airdrop/page/home.dart';
import 'package:airdrop/page/login.dart';
import 'package:airdrop/services/admin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:airdrop/services/post.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/auto_scroll_crypto_row.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/post.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:select_dialog/select_dialog.dart';

TextEditingController postController = TextEditingController();
ValueNotifier<List<Widget>> profilePosts = ValueNotifier([]);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ValueNotifier<List<Widget>> profileCrypto = ValueNotifier([]);
  ValueNotifier<bool> bioLong = ValueNotifier(false);
  List<List<String>> social = [];
  List<String> socialText = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadProfileCrypto);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 🔥 ANA FONKSİYON: Crypto'ları yükle ve göster
  Future<void> _loadProfileCrypto() async {
    try {
      await MyProfileData.getMyProfile();
      if (!mounted) return;

      var cryptoPoolRaw = await ByBugDatabase.getAll("crypto");
      List<Map<String, dynamic>> cryptoPool = [];
      for (var element in cryptoPoolRaw) {
        Map<String, dynamic> val = Map<String, dynamic>.from(
          element["value"] ?? {},
        );
        if ((val["name"] ?? "").toString().isEmpty) continue;
        if ((val["image"] ?? "").toString().isEmpty) continue;
        cryptoPool.add(val);
      }

      var finalCryptos = fillToThreeCryptos(
        MyProfileData.cripto(),
        cryptoPool,
      );

      profileCrypto.value.clear();

      for (var element in finalCryptos) {
        profileCrypto.value.add(
          GestureDetector(
            onTap: () {
              _showCryptoDetail(context, element);
            },
            // 🔥 BURASI ÇOK ÖNEMLİ: Uzun basınca favoriden çıkarma
            onLongPress: () {
              _showRemoveFavoriteDialog(context, element);
            },
            child: Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: (element["image"] ?? "").toString().isNotEmpty
                    ? Colors.transparent
                    : Colors.orange,
                borderRadius: BorderRadius.circular(35),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: (element["image"] ?? "").toString().isNotEmpty
                    ? AirdroptourImage(
                        (element["image"]).toString(),
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      )
                    : Text(
                        (element["name"] ?? "?").toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
          ),
        );
      }

      profileCrypto.notifyListeners();
      debugPrint("DEBUG profil cripto sayisi: ${MyProfileData.cripto().length}");

      var socialData = MyProfileData.social();
      social.clear();
      for (var element in socialData.keys) {
        Map<String, dynamic> value = socialData[element];
        social.add([value["name"], value["url"]]);
        socialText.add(value["name"]);
      }

      Post.getProfilePosts(MyProfileData.uid());
    } catch (e) {
      debugPrint("❌ _loadProfileCrypto hatası: $e");
      profileCrypto.value.clear();
      profileCrypto.notifyListeners();
    }
  }

  // 🔥 YENİ: Crypto detay göster
  void _showCryptoDetail(BuildContext context, Map<String, dynamic> element) {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: (element["image"] ?? "").toString().isNotEmpty
                          ? AirdroptourImage(
                              (element["image"]).toString(),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              color: Colors.orange,
                              alignment: Alignment.center,
                              child: Text(
                                (element["name"] ?? "?").toString(),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black),
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: h3((element["name"] ?? "").toString()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                subP((element["details"] ?? "").toString()),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CryptoWidget.exchangeLinks.entries.map((entry) {
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
                        padding: const EdgeInsets.symmetric(
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
                  }).toList(),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("⚠️ Crypto detay gösterilemedi: $e");
    }
  }

  // 🔥 YENİ: Favori coin silme dialog'u
  void _showRemoveFavoriteDialog(
      BuildContext context, Map<String, dynamic> coin) {
    String coinName = coin["name"]?.toString() ?? "Bu coin";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: navColor,
        title: Text("Remove from Favorites", style: TextStyle(color: textColor)),
        content: Text(
          "Are you sure you want to remove $coinName from favorites?",
          style: TextStyle(color: textColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: textColor)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _removeFavoriteCoin(coinName);
            },
            child: Text(
              "Remove",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 YENİ: Favori coin silme işlemi
  Future<void> _removeFavoriteCoin(String coinName) async {
    try {
      List currentFavorites = MyProfileData.cripto();
      if (currentFavorites == null) currentFavorites = [];

      currentFavorites.removeWhere((element) {
        if (element is Map) {
          return element["name"] == coinName;
        }
        return false;
      });

      await MyProfileData.setProfile(
        cripto: currentFavorites,
      );

      await _loadProfileCrypto();

      if (mounted) {
        getSuccessSnack(context, "$coinName favorilerden çıkarıldı");
      }
    } catch (e) {
      debugPrint("❌ Favori coin silme hatası: $e");
      if (mounted) {
        getErrorSnack(context, "Coin çıkarılamadı: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 BURASI ÇOK ÖNEMLİ: Geri tuşu HOME'a yönlendir (Login'e değil!)
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: SizerResponsive(
        child: Scaffold(
          backgroundColor: bg,
          body: BottomPage(
            page: 4,
            child: ListenableBuilder(
              listenable: Listenable.merge([
                bioLong,
                MyProfileData.data,
                profileCrypto,
                profilePosts,
              ]),
              builder: (context, child) {
                return SafeArea(
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              // 🟢 PROFİL BAŞLIĞI
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: defaultColor,
                                        borderRadius:
                                            BorderRadius.circular(1020),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    h1("My Profile"),
                                  ],
                                ),
                              ),

                              // 🟢 PROFİL RESİM + İSİM + POST SAYISI
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
                                        MyProfileData.photo().startsWith("http")
                                            ? MyProfileData.photo()
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
                                                visible:
                                                    MyProfileData.premium(),
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
                                                  MyProfileData.name(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  MyProfileData.isAdmin()
                                                      ? "Admin/Developer Account"
                                                      : "User Account",
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                          profilePosts.value.length.toString(),
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

                              // 🟢 BİO + SOSYAL MEDYA
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
                                              MyProfileData.bio(),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: MyProfileData.bio().length > 100,
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

                              // 🟢 BUTONLAR
                              _buildMenuItem(
                                icon: Icons.settings_outlined,
                                title: "Edit Profile",
                                onTap: () => push(context, EditPage()),
                              ),
                              _buildMenuItem(
                                icon: Icons.radar_outlined,
                                title: "Contact Us",
                                onTap: () => push(context, Contact()),
                              ),
                              if (MyProfileData.isAdmin())
                                _buildMenuItem(
                                  icon: Icons.admin_panel_settings,
                                  title: "Administration Panel",
                                  onTap: () => push(context, AdminPanel()),
                                ),
                              _buildMenuItem(
                                icon: Icons.add_box_outlined,
                                title: "Create New Post",
                                onTap: () => addPost(context),
                              ),
                              _buildMenuItem(
                                icon: Icons.logout,
                                title: "Sign Out",
                                color: Colors.red,
                                onTap: () async {
                                  await ByBugAuth.logout();
                                  if (!context.mounted) return;
                                  push(context, LoginPage());
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.delete_forever,
                                title: "Delete My Account",
                                color: Colors.red,
                                isDelete: true,
                                onTap: () async {
                                  // Delete Account işlemi
                                  final confirm1 = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: navColor,
                                      title: bold("Delete Account"),
                                      content: p(
                                        "This will permanently delete your account, profile, and login credentials. This action cannot be undone.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: p("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: bold("Continue"),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm1 != true) return;
                                  if (!context.mounted) return;

                                  final confirm2 = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: navColor,
                                      title: bold("Are you absolutely sure?"),
                                      content: p(
                                        "Last chance to cancel. Your account will be gone forever.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: p("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: bold("Delete Forever"),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm2 != true) return;

                                  var x = await ByBugAuth.deleteSelf();
                                  if (x[0] == 1) {
                                    await ByBugAuth.logout();
                                    if (!context.mounted) return;
                                    push(context, LoginPage());
                                  } else {
                                    if (context.mounted) {
                                      getErrorSnack(context, x[1]);
                                    }
                                  }
                                },
                              ),

                              // 🟢 CRYPTO ROW
                              ValueListenableBuilder<List<Widget>>(
                                valueListenable: profileCrypto,
                                builder: (context, cryptoChildren, _) {
                                  return SizedBox(
                                    width: widthSizer(context),
                                    child: AutoScrollCryptoRow(
                                      children: cryptoChildren,
                                    ),
                                  );
                                },
                              ),

                              // 🟢 POSTLAR
                              Column(children: profilePosts.value),
                              const SizedBox(height: 100),
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
      ),
    );
  }

  // 🔥 YARDIMCI WIDGET: Menü öğesi
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
    bool isDelete = false,
  }) {
    return Column(
      children: [
        SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            padding: EdgeInsets.all(10),
            width: widthSizer(context),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDelete
                    ? [bg, Colors.red.withOpacity(0.3)]
                    : [bg, navColor],
              ),
              borderRadius: BorderRadius.circular(10),
              border: isDelete
                  ? Border.all(color: Colors.red.withOpacity(0.5))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDelete ? Colors.red.withOpacity(0.8) : color,
                  ),
                ),
                Spacer(),
                Icon(
                  icon,
                  color: isDelete ? Colors.red.withOpacity(0.8) : color,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void addPost(BuildContext context) {
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
                  children: [
                    SizedBox(height: 10),
                    h3("Post", color: defaultColor),
                    p("Create New Post"),
                    SizedBox(height: 10),
                    Expanded(
                      child: textfield(
                        text: "write something...",
                        textController: postController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        if (postController.text.trim().isNotEmpty) {
                          await Post.add();
                          if (!context.mounted) return;
                          pop(context);
                        }
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
          ],
        ),
      );
    },
  );
}