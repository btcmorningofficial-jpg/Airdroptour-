import 'package:airdrop/page/admin/rains.dart';
import 'package:airdrop/services/admin.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/rain.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:flutter/material.dart';

class RainExplorerPage extends StatefulWidget {
  const RainExplorerPage({super.key});

  @override
  State<RainExplorerPage> createState() => _RainExplorerPageState();
}

class _RainExplorerPageState extends State<RainExplorerPage> {
  Future<void> getRains() async {
    var list = await ByBugDatabase.getAll("rain");
    List<Widget> ms = [];
    rainWidgets.value.clear();
    for (var element in list) {
      if (element["value"]["status"] == "active") {
        for (var m in element["value"]["mission"]) {
          ms.add(
            rainMission(
              m["id"],
              m["title"],
              m["link"],
              m["joiner"],
              element["value"],
              element["tag"],
            ),
          );
        }
        rainWidgets.value.add(
          RainComponent(
            missions: ms,
            value: element["value"],
            tag: element["tag"],
            award: element["value"]["award"],
            name: element["value"]["title"],
            uid: element["value"]["uid"] ?? "",
            about: element["value"]["about"],
            status: element["value"]["status"],
          ),
        );
      }
    }
    rainWidgets.notifyListeners();
  }

  @override
  void initState() {
    super.initState();
    getRains();
  }

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            BottomPage(
              page: 2,
              child: ListenableBuilder(
                listenable: Listenable.merge([MyProfileData.data, rainWidgets]),
                builder: (context, child) {
                  return SafeArea(
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
                                        borderRadius: BorderRadius.circular(
                                          1020,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    h1("rains"),
                                    Spacer(),

                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(children: rainWidgets.value),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rainMission(
    String id,
    String title,
    String link,
    Map joiner,
    Map<String, dynamic> generalValue,
    String tag,
  ) {
    bool isOk = false;
    ValueNotifier<bool> visib = ValueNotifier(true);
    for (var element in joiner.keys.toList()) {
      if (element == MyProfileData.uid()) {
        isOk = true;
        break;
      }
    }
    return ValueListenableBuilder(
      valueListenable: visib,
      builder: (BuildContext context, dynamic value, Widget? child) {
        return Visibility(
          visible: value,
          child: Container(
            padding: EdgeInsets.all(6),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: navColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(5),
            ),
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.red),
                SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [bold(title), p("This task was not completed")],
                  ),
                ),
                GestureDetector(
                  onTap: isOk
                      ? () {}
                      : () async {
                          Map<String, dynamic> val = generalValue;
                          for (var element in val["mission"]) {
                            if (element["id"] == id) {
                              var x = val["mission"].indexOf(element);
                              val["mission"][x]["joiner"].addAll({
                                MyProfileData.uid(): "ok",
                              });
                              break;
                            }
                          }
                          await ByBugDatabase.update("rain", tag, val);
                          visib.value = false;
                          visib.notifyListeners();
                        },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOk ? defaultColor : Colors.red,
                      borderRadius: BorderRadius.circular(1020),
                    ),
                    child: bold(isOk ? "Mission Done!" : "Do the Task"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
