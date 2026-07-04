import 'dart:io';

import 'package:airdrop/page/login.dart';
import 'package:airdrop/page/register.dart';
import 'package:airdrop/services/auth.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  void getSocial() async {
    var socialData = MyProfileData.social();
    social.value.clear();
    for (var element in socialData.keys) {
      Map<String, dynamic> value = socialData[element];
      social.value.add(
        SocialMediaEdit(
          name: value["name"],
          link: value["url"],
          id: element,
          onDelete: () async {
            await MyProfileData.getMyProfile();
            var sm = MyProfileData.social();
            sm.remove(element);
            await MyProfileData.setProfile(social: sm);
            MyProfileData.getMyProfile();
            getSocial();
          },
        ),
      );
    }
    social.notifyListeners();
  }

  TextEditingController bioController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  TextEditingController addSMName = TextEditingController();
  TextEditingController addSMURI = TextEditingController();
  ValueNotifier<String> imageController = ValueNotifier("");
  ValueNotifier<List<Widget>> social = ValueNotifier([]);
  @override
  void initState() {
    super.initState();
    bioController.text = MyProfileData.bio();
    nameController.text = MyProfileData.name();
    imageController.value = MyProfileData.photo();
    imageController.notifyListeners();
    getSocial();
  }

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: ListenableBuilder(
          listenable: Listenable.merge([imageController, social]),
          builder: (context, child) {
            return Column(
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
                      h1("Edit Profile"),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios, color: textColor),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    String? image = await pickImage();
                    if (image == null) return;
                    String? uploaded = await ByBugStorage.uploadFile(image);
                    if (uploaded == null) return;
                    imageController.value = uploaded;
                    imageController.notifyListeners();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.only(
                        topLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      child: AirdroptourImage(
                        imageController.value.startsWith("http")
                            ? imageController.value
                            : "assets/img/user.png",
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                textfield(
                  text: "Username",
                  textController: nameController,
                  keyboardType: TextInputType.name,
                ),
                textfield(
                  text: "Biography",
                  textController: bioController,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 10),
                Opacity(opacity: 0.5, child: h3("•")),
                SizedBox(height: 10),
                Column(children: social.value),
                SizedBox(height: 10),
                addSM(context),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    await MyProfileData.setProfile(
                      bio: bioController.text,
                      photo: imageController.value,
                      name: nameController.text,
                    );
                    if (!context.mounted) return;
                    pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    width: widthSizer(context),
                    decoration: BoxDecoration(
                      color: defaultColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: h5("Update")),
                  ),
                ),

                SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }

  GestureDetector addSM(BuildContext context) {
    return GestureDetector(
      onTap: () async {
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
                    child: IntrinsicHeight(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        width: widthSizer(context) * 0.9,
                        decoration: BoxDecoration(
                          color: navColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            h3("My Social Media", color: defaultColor),
                            p("Add new social media account"),
                            SizedBox(height: 10),
                            textfield(
                              text: "Platform Name",
                              textController: addSMName,
                              keyboardType: TextInputType.name,
                            ),
                            textfield(
                              text: "Profile Link",
                              textController: addSMURI,
                              keyboardType: TextInputType.url,
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                if (addSMURI.text.contains("http")) {
                                  await MyProfileData.getMyProfile();
                                  var sm = MyProfileData.social();
                                  var id = CosmosRandom.randomTag();
                                  sm.addAll({
                                    id: {
                                      "name": addSMName.text,
                                      "url": addSMURI.text,
                                      "create_at": id,
                                    },
                                  });
                                  await MyProfileData.setProfile(social: sm);

                                  if (!context.mounted) return;
                                  pop(context);
                                  MyProfileData.getMyProfile();
                                  getSocial();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 4,
                                ),
                                width: widthSizer(context),
                                decoration: BoxDecoration(
                                  color: defaultColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(child: h5("Add")),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
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
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        width: widthSizer(context),
        decoration: BoxDecoration(
          color: navColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: h5("Add Social Media")),
      ),
    );
  }
}

class SocialMediaEdit extends StatelessWidget {
  final String name;
  final String link;
  final String id;
  final Function() onDelete;
  const SocialMediaEdit({
    super.key,
    required this.name,
    required this.link,
    required this.id,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await openUrl(link);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        width: widthSizer(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [bg, navColor]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.link, color: textColor),
            SizedBox(width: 5),
            Expanded(child: bold(name)),
            GestureDetector(
              onTap: () {
                onDelete();
              },
              child: Icon(Icons.remove, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
