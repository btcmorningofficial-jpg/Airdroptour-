import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class AddRain extends StatefulWidget {
  const AddRain({super.key});

  @override
  State<AddRain> createState() => _AddRainState();
}

class _AddRainState extends State<AddRain> {
  ValueNotifier<List<Map<String, dynamic>>> missions = ValueNotifier([]);
  ValueNotifier<List<Widget>> missionsW = ValueNotifier([]);
  TextEditingController name = TextEditingController();
  TextEditingController about = TextEditingController();
  TextEditingController award = TextEditingController();
  void loadMission() {
    missionsW.value.clear();
    for (var element in missions.value) {
      missionsW.value.add(
        rainMission(element["id"], element["title"], element["link"]),
      );
    }
    missionsW.notifyListeners();
  }

  void remove(String id) {
    int x = -1;
    for (var element in missions.value) {
      if (element["id"] == id) {
        x = missions.value.indexOf(element);
      }
    }
    missions.value.removeAt(x);
    loadMission();
  }

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: ListenableBuilder(
          listenable: Listenable.merge([missions, missionsW]),
          builder: (context, child) {
            return SingleChildScrollView(
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
                        h1("Add Rain"),
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
                  textfield(
                    text: "Rain Cap",
                    textController: name,
                    keyboardType: TextInputType.name,
                  ),
                  textfield(
                    text: "Rain Explanation (Markdown Supported!)",
                    textController: about,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  textfield(
                    text: "Award Description",
                    textController: award,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 10),
                  Opacity(opacity: 0.5, child: h3("•")),
                  SizedBox(height: 10),
                  Column(children: missionsW.value),
                  SizedBox(height: 10),
                  addSM(context),
                  SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      await ByBugDatabase.add(
                        "rain",
                        CosmosRandom.randomTag() + CosmosRandom.string(5),
                        {
                          "title": name.text,
                          "about": about.text,
                          "award": award.text,
                          "mission": missions.value,
                          "uid": MyProfileData.uid(),
                          "status": "pending",
                        },
                      );
                      if (!context.mounted) return;
                      getSuccessSnack(context, "Successful!");
                      await Future.delayed(Durations.medium1);
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
                      child: Center(child: h5("Submit for Review")),
                    ),
                  ),

                  SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Container rainMission(String id, String title, String link) {
    return Container(
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
              children: [bold(title), p("Users will perform this task.")],
            ),
          ),
          GestureDetector(
            onTap: () {
              remove(id);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(1020),
              ),
              child: bold("Remove Task"),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector addSM(BuildContext context) {
    TextEditingController missionTitle = TextEditingController();
    TextEditingController missionLink = TextEditingController();
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
                            h3("New Mission", color: defaultColor),
                            p("Add new task"),
                            SizedBox(height: 10),
                            textfield(
                              text: "Task Title",
                              textController: missionTitle,
                              keyboardType: TextInputType.name,
                            ),
                            textfield(
                              text: "Task Link",
                              textController: missionLink,
                              keyboardType: TextInputType.url,
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                missions.value.add({
                                  "id": CosmosRandom.password(),
                                  "title": missionTitle.text,
                                  "link": missionLink.text,
                                  "joiner": {},
                                });
                                loadMission();
                                pop(context);
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
        child: Center(child: h5("Add Mission")),
      ),
    );
  }
}
