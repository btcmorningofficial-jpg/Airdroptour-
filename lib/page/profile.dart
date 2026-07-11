import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/page/add_rain.dart';
import 'package:airdrop/page/admin/admin.dart';
import 'package:airdrop/page/contact.dart';
import 'package:airdrop/page/edit.dart';
import 'package:airdrop/page/login.dart';
import 'package:airdrop/services/admin.dart';
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
    MyProfileData.getMyProfile();
    for (var element in MyProfileData.cripto()) {
      if (AdminServices.cryptosNames.contains(element["image"])) {
        profileCrypto.value.add(
          CryptoWidget(
            id: "id",
            photo: element["image"],
            name: element["name"],
            details: element["details"],
          ),
        );
      }
    }
    profileCrypto.notifyListeners();
    var socialData = MyProfileData.social();
    social.clear();
    for (var element in socialData.keys) {
      Map<String, dynamic> value = socialData[element];
      social.add([value["name"], value["url"]]);
      socialText.add(value["name"]);
    }
    Post.getProfilePosts(MyProfileData.uid());
  }

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
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
                                  h1("My Profile"),
                                ],
                              ),
                            ),
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
                                              visible: MyProfileData.premium(),
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                            GestureDetector(
                              onTap: () {
                                push(context, EditPage());
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.all(10),
                                width: widthSizer(context),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [bg, navColor],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    p("Edit Profile"),
                                    Spacer(),
                                    Icon(
                                      Icons.settings_outlined,
                                      color: textColor,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                push(context, Contact());
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.all(10),
                                width: widthSizer(context),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [bg, navColor],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    p("Contact Us"),
                                    Spacer(),
                                    Icon(
                                      Icons.radar_outlined,
                                      color: textColor,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: MyProfileData.isAdmin(),
                              child: Column(
                                children: [
                                  SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      push(context, AdminPanel());
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      padding: EdgeInsets.all(10),
                                      width: widthSizer(context),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [bg, navColor],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          p("Administration Panel"),
                                          Spacer(),
                                          Icon(
                                            Icons.admin_panel_settings,
                                            color: textColor,
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                addPost(context);
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.all(10),
                                width: widthSizer(context),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [bg, navColor],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    p("Create New Post"),
                                    Spacer(),
                                    Icon(
                                      Icons.add_box_outlined,
                                      color: textColor,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            GestureDetector(
                              onTap: () async {
                                await ByBugAuth.logout();
                                if (!context.mounted) return;
                                push(context, LoginPage());
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.all(10),
                                width: widthSizer(context),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [bg, Colors.red],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    p("Sign Out"),
                                    Spacer(),
                                    Icon(
                                      Icons.logout,
                                      color: textColor,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            GestureDetector(
                              onTap: () async {
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
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.all(10),
                                width: widthSizer(context),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Delete My Account",
                                      style: TextStyle(
                                        color: Colors.red.withOpacity(0.8),
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.delete_forever,
                                      color: Colors.red.withOpacity(0.8),
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: h3("•", color: textColor.withOpacity(0.5)),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: AutoScrollCryptoRow(
                                    children: profileCrypto.value,
                                  ),
                                ),
                              ],
                            ),
                            Column(children: profilePosts.value),
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
