import 'package:airdrop/page/rain_content.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';

class RainComponent extends StatefulWidget {
  final String award;
  final String name;
  final String about;
  final String uid;
  final String status;
  final String tag;
  final Map<String, dynamic> value;
  final List<Widget> missions;
  const RainComponent({
    super.key,
    required this.award,
    required this.name,
    required this.uid,
    required this.about,
    required this.status,
    required this.value,
    required this.tag,
    required this.missions,
  });

  @override
  State<RainComponent> createState() => _RainComponentState();
}

class _RainComponentState extends State<RainComponent> {
  ValueNotifier<String> statusValue = ValueNotifier("active");
  @override
  void initState() {
    super.initState();
    statusValue.value = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([statusValue]),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            push(
              context,
              RainContent(
                missions: widget.missions,
                about: widget.about,
                award: widget.award,
                name: widget.name,
                status: widget.status,
                tag: widget.tag,
                uid: widget.uid,
              ),
            );
          },
          child: Container(
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
                  "Reward",
                  widget.award,
                ),
              ],
            ),
          ),
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
