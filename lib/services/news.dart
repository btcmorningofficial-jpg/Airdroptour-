import 'package:airdrop/page/admin/news.dart';
import 'package:airdrop/page/news_content.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:select_dialog/select_dialog.dart';

class News extends ChangeNotifier {
  static ValueNotifier<List<Widget>> newsList = ValueNotifier([]);
  static ValueNotifier<List<Widget>> newsListHome = ValueNotifier([]);
  static ValueNotifier<String> image = ValueNotifier("");
  static ValueNotifier<String> title = ValueNotifier("");
  static ValueNotifier<String> newsText = ValueNotifier("");
  static ValueNotifier<String> createAt = ValueNotifier("");
  static ValueNotifier<List> like = ValueNotifier([]);
  static Future<void> add(String title, String newsText, String image) async {
    await ByBugDatabase.add(
      "news",
      "news_${CosmosRandom.randomTag() + CosmosRandom.string(5)}",
      {
        "image": image,
        "title": title,
        "newsText": newsText,
        "create_at": DateTime.now().toString(),
        "like": [],
      },
    );
  }

  static Future<void> get(String tag) async {
    var newsData = await ByBugDatabase.get("news", tag);
    image = newsData["value"]["image"];
    title = newsData["value"]["title"];
    newsText = newsData["value"]["newsText"];
    createAt = newsData["value"]["create_at"];
    like = newsData["value"]["like"];
    image.notifyListeners();
    title.notifyListeners();
    newsText.notifyListeners();
    createAt.notifyListeners();
    like.notifyListeners();
  }

  static Future<void> getAll(BuildContext context) async {
    var news = await ByBugDatabase.getAll("news");
    newsList.value.clear();
    List<NewsComponent> list = [];
    List<NewsComponent> listHome = [];
    for (var element in news) {
      list.add(
        NewsComponent(
          tag: element["tag"],
          photo: element["value"]["image"],
          name: element["value"]["title"],
          details: element["value"]["newsText"],
          dateTime: DateTime.parse(element["value"]["create_at"]),
          onTap: () async {
            await SelectDialog.showModal<String>(
              context,
              searchHint: "Seçenekler içinde ara",
              label: "Habere Dair",
              backgroundColor: navColor,
              constraints: BoxConstraints(maxWidth: width(context) * 0.5),
              items: ["Haberi Görüntüle", "Haberi Sil"],
              onChange: (p0) async {
                if (p0 == "Haberi Sil") {
                  await ByBugDatabase.remove("news", element["tag"]);
                  await Future.delayed(Durations.extralong4);
                  if (!context.mounted) return;
                  await getAll(context);
                } else if (p0 == "Haberi Görüntüle") {
                  await Future.delayed(Durations.extralong4);
                  if (!context.mounted) return;
                  push(
                    context,
                    NewsContent(
                      tag: element["tag"],
                      photo: element["value"]["image"],
                      name: element["value"]["title"],
                      details: element["value"]["newsText"],
                      dateTime: DateTime.parse(element["value"]["create_at"]),
                    ),
                  );
                }
              },
            );
          },
        ),
      );
      listHome.add(
        NewsComponent(
          tag: element["tag"],
          photo: element["value"]["image"],
          name: element["value"]["title"],
          details: element["value"]["newsText"],
          dateTime: DateTime.parse(element["value"]["create_at"]),
          onTap: () {
            push(
              context,
              NewsContent(
                tag: element["tag"],
                photo: element["value"]["image"],
                name: element["value"]["title"],
                details: element["value"]["newsText"],
                dateTime: DateTime.parse(element["value"]["create_at"]),
              ),
            );
          },
        ),
      );
    }
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    listHome.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    newsList.value = list;
    newsListHome.value = listHome;
    newsList.notifyListeners();
    newsListHome.notifyListeners();
  }

  static void addNews(BuildContext context) async {
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
                            h3("News", color: defaultColor),
                            p("Add New News"),
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
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            textfield(
                              text: "News Title",
                              textController: varlikName,
                              keyboardType: TextInputType.name,
                              maxLines: 1,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(120),
                              ],
                            ),
                            textfield(
                              text: "News Content",
                              textController: varlikDetails,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(3000),
                              ],
                            ),

                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                await add(
                                  varlikName.text,
                                  varlikDetails.text,
                                  imgCripto.value,
                                );
                                if (!context.mounted) return;
                                pop(context);
                                getSuccessSnack(context, "News Added");
                                await News.getAll(context);
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
