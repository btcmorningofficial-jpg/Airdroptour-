import 'package:airdrop/services/admin.dart';
import 'package:airdrop/services/news.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/get_time.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/markdown.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';

class NewsAdmin extends StatefulWidget {
  const NewsAdmin({super.key});

  @override
  State<NewsAdmin> createState() => _NewsAdminState();
}

class _NewsAdminState extends State<NewsAdmin> {
  @override
  void initState() {
    super.initState();
    News.getAll(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([News.newsList]),
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  News.addNews(context);
                },
                child: Opacity(
                  opacity: 0.5,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: EdgeInsets.all(10),
                    width: widthSizer(context),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: navColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [bold("Add New News")],
                    ),
                  ),
                ),
              ),

              Column(children: News.newsList.value),
              SizedBox(height: 66),
            ],
          ),
        );
      },
    );
  }
}

class NewsComponent extends StatelessWidget {
  final String tag;
  final String photo;
  final String name;
  final String details;
  final DateTime dateTime;
  final Function() onTap;
  const NewsComponent({
    super.key,
    required this.tag,
    required this.photo,
    required this.name,
    required this.details,
    required this.dateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            Visibility(
              visible: photo.startsWith("http"),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
                child: AirdroptourImage(
                  photo,
                  width: widthSizer(context),
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: widthSizer(context),
              decoration: BoxDecoration(
                color: navColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  h3(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    color: defaultColor,
                  ),
                  SizedBox(height: 4),
                  Opacity(opacity: 0.8, child: subP(getDateEN(dateTime))),
                  SizedBox(height: 4),
                  p(
                    details.replaceAll("\n", " "),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
