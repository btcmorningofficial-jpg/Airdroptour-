import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';

class AdminUserComponent extends StatefulWidget {
  final String photo;
  final String name;
  final String email;
  final String uid;
  final String status;
  final bool verify;
  final bool isAdmin;
  const AdminUserComponent({
    super.key,
    required this.photo,
    required this.name,
    required this.uid,
    required this.email,
    required this.isAdmin,
    required this.status,
    required this.verify,
  });

  @override
  State<AdminUserComponent> createState() => _AdminUserComponentState();
}

class _AdminUserComponentState extends State<AdminUserComponent> {
  ValueNotifier<bool> premiumValue = ValueNotifier(false);
  ValueNotifier<bool> adminValue = ValueNotifier(false);
  ValueNotifier<String> statusValue = ValueNotifier("active");
  @override
  void initState() {
    super.initState();
    premiumValue.value = widget.verify;
    adminValue.value = widget.isAdmin;
    statusValue.value = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([premiumValue, adminValue, statusValue]),
      builder: (context, child) {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              padding: EdgeInsets.all(10),
              width: widthSizer(context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: navColor.withOpacity(0.8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadiusGeometry.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: AirdroptourImage(
                          widget.photo.startsWith("http")
                              ? widget.photo
                              : "assets/img/user.png",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Visibility(
                                  visible: premiumValue.value ? true : false,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        color: Colors.indigoAccent,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                    ],
                                  ),
                                ),
                                Expanded(child: bold(widget.name)),
                              ],
                            ),
                            subP(widget.email),
                          ],
                        ),
                      ),
                      Icon(
                        adminValue.value
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        color: adminValue.value ? defaultColor : textColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildUserData(Icons.person, "Profile Name", widget.name),
                  _buildUserData(
                    Icons.person,
                    "Premium Account",
                    premiumValue.value ? "Yes" : "No",
                  ),
                  _buildUserData(
                    Icons.person,
                    "Administrator",
                    adminValue.value ? "Yes" : "No",
                  ),
                  _buildUserData(
                    Icons.person,
                    "Status",
                    statusValue.value == "active"
                        ? "Active"
                        : statusValue.value == "ban"
                        ? "Hanging"
                        : "Inactive",
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await SelectDialog.showModal<String>(
                  context,
                  searchHint: "Search",
                  label: "Premium",
                  backgroundColor: navColor,
                  constraints: BoxConstraints(maxWidth: width(context) * 0.5),
                  items: ["Make it Premium", "Premium Remove"],
                  onChange: (p0) async {
                    if ("Make it Premium" == p0) {
                      await MyProfileData.setProfile(
                        uidss: widget.uid,
                        verify: true,
                      );
                      premiumValue.value = true;
                      premiumValue.notifyListeners();
                    } else if ("Premium Remove" == p0) {
                      await MyProfileData.setProfile(
                        uidss: widget.uid,
                        verify: false,
                      );
                      premiumValue.value = false;
                      premiumValue.notifyListeners();
                    }
                  },
                );
              },
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  padding: EdgeInsets.all(10),
                  width: widthSizer(context),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: navColor.withOpacity(0.8),
                  ),
                  child: Row(
                    children: [
                      bold("Premium: "),
                      Expanded(child: p(premiumValue.value ? "Yes" : "No")),
                      subP("  change  "),
                      Icon(Icons.refresh_rounded, color: textColor),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await SelectDialog.showModal<String>(
                  context,
                  searchHint: "Search",
                  label: "Administrator",
                  backgroundColor: navColor,
                  constraints: BoxConstraints(maxWidth: width(context) * 0.5),
                  items: ["Make Administrator", "Remove Administrator"],
                  onChange: (p0) async {
                    if ("Make Administrator" == p0) {
                      await MyProfileData.setProfile(
                        uidss: widget.uid,
                        isAdmin: true,
                      );
                      adminValue.value = true;
                      adminValue.notifyListeners();
                    } else if ("Remove Administrator" == p0) {
                      await MyProfileData.setProfile(
                        uidss: widget.uid,
                        isAdmin: false,
                      );
                      adminValue.value = false;
                      adminValue.notifyListeners();
                    }
                  },
                );
              },
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  padding: EdgeInsets.all(10),
                  width: widthSizer(context),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: navColor.withOpacity(0.8),
                  ),
                  child: Row(
                    children: [
                      bold("Administrator: "),
                      Expanded(child: p(adminValue.value ? "Yes" : "No")),
                      subP("  change  "),
                      Icon(Icons.refresh_rounded, color: textColor),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await SelectDialog.showModal<String>(
                  context,
                  searchHint: "Search",
                  label: "Status",
                  backgroundColor: navColor,
                  constraints: BoxConstraints(maxWidth: width(context) * 0.5),
                  items: [
                    "Account: Active",
                    "Account: Inactive",
                    "Account: Ban / Block",
                  ],
                  onChange: (p0) async {
                    if ("Account: Active" == p0) {
                      await MyProfileData.setProfile(
                        uidss: widget.uid,
                        status: "active",
                      );
                      statusValue.value = "active";
                      statusValue.notifyListeners();
                    } else if ("Account: Inactive" == p0) {
                      await MyProfileData.setProfile(
                        uidss: widget.uid,
                        status: "deactive",
                      );
                      statusValue.value = "deactive";
                      statusValue.notifyListeners();
                    } else if ("Account: Ban / Block" == p0) {
                      await MyProfileData.setProfile(
                        uidss: widget.uid,
                        status: "ban",
                      );
                      statusValue.value = "ban";
                      statusValue.notifyListeners();
                    }
                  },
                );
              },
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  padding: EdgeInsets.all(10),
                  width: widthSizer(context),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: navColor.withOpacity(0.8),
                  ),
                  child: Row(
                    children: [
                      bold("Status: "),
                      Expanded(
                        child: p(
                          statusValue.value == "active"
                              ? "Active"
                              : statusValue.value == "ban"
                              ? "Hanging"
                              : "Inactive",
                        ),
                      ),
                      subP("  change  "),
                      Icon(Icons.refresh_rounded, color: textColor),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Row _buildUserData(IconData icon, String tag, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: defaultColor),
        SizedBox(width: 4),
        bold("$tag: "),
        Expanded(child: p(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
