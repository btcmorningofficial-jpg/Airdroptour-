import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';

class AdminRainComponent extends StatefulWidget {
  final String award;
  final String name;
  final String about;
  final String uid;
  final String status;
  final String tag;
  final Map<String, dynamic> value;
  const AdminRainComponent({
    super.key,
    required this.award,
    required this.name,
    required this.uid,
    required this.about,
    required this.status,
    required this.value,
    required this.tag,
  });

  @override
  State<AdminRainComponent> createState() => _AdminRainComponentState();
}

class _AdminRainComponentState extends State<AdminRainComponent> {
  ValueNotifier<String> statusValue = ValueNotifier("active");
  bool _deleted = false;
  @override
  void initState() {
    super.initState();
    statusValue.value = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted) {
      return const SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: Listenable.merge([statusValue]),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [bold(widget.name), subP(widget.about)],
                        ),
                      ),
                      //
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildUserData(
                    Icons.card_giftcard_rounded,
                    "Award Text",
                    widget.award,
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
                  label: "Status",
                  backgroundColor: navColor,
                  constraints: BoxConstraints(maxWidth: width(context) * 0.5),
                  items: ["pending", "on air", "rejected", "delete (permanent)"],
                  onChange: (p0) async {
                    if ("on air" == p0) {
                      Map<String, dynamic> val = widget.value;
                      val["status"] = "active";
                      statusValue.value = "active";
                      await ByBugDatabase.update("rain", widget.tag, val);
                    } else if ("rejected" == p0) {
                      Map<String, dynamic> val = widget.value;
                      val["status"] = "";
                      statusValue.value = "";
                      await ByBugDatabase.update("rain", widget.tag, val);
                    } else if ("pending" == p0) {
                      Map<String, dynamic> val = widget.value;
                      val["status"] = "pending";
                      statusValue.value = "pending";
                      await ByBugDatabase.update("rain", widget.tag, val);
                    } else if ("delete (permanent)" == p0) {
                      // SelectDialog kapanma animasyonu bitmeden yeni bir
                      // dialog açmaya çalışmak sessizce başarısız olabiliyor;
                      // bir sonraki frame'e kadar bekliyoruz.
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (!context.mounted) return;

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: navColor,
                          title: bold("Delete Rain"),
                          content: p(
                            "${widget.name} will be permanently deleted. This action cannot be undone. Are you sure?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: p("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: bold("Delete"),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await ByBugDatabase.remove("rain", widget.tag);
                          if (mounted) {
                            setState(() {
                              _deleted = true;
                            });
                          }
                        } catch (e) {
                          if (context.mounted) {
                            getErrorSnack(context, "Delete failed: $e");
                          }
                        }
                      }
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
                          statusValue.value == "pending"
                              ? "pending"
                              : statusValue.value == "active"
                              ? "on air"
                              : "rejected.",
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
