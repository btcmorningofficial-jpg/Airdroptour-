import 'package:airdrop/services/admin.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/markdown.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as slider;

class AirdroptourSlider {
  static Widget classic(
    List data, {
    double? imageWidth,
    double? imageHeight,
    bool? autoPlay,
    Duration? autoPlayAnimationDuration,
  }) {
    return slider.CarouselSlider.builder(
      itemCount: data.length,
      options: slider.CarouselOptions(
        autoPlay: autoPlay ?? true,
        aspectRatio: 2.0,
        enlargeCenterPage: true,
        autoPlayAnimationDuration:
            autoPlayAnimationDuration ?? const Duration(milliseconds: 800),
      ),
      itemBuilder: (context, index, realIdx) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onTap: () {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  h5(
                                    (AdminServices.getValuesAds(data[index]) ??
                                            {})["name"] ??
                                        "",
                                  ),
                                  Expanded(
                                    child: markdownText(
                                      (AdminServices.getValuesAds(
                                                data[index],
                                              ) ??
                                              {})["details"] ??
                                          "",
                                    ),
                                  ),

                                  SizedBox(height: 10),

                                  GestureDetector(
                                    onTap: () async {
                                      pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      width: widthSizer(context),
                                      decoration: BoxDecoration(
                                        color: cColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(child: h5("Close")),
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
              },
              child: AirdroptourImage(
                data[index],
                fit: BoxFit.cover,
                width: imageWidth ?? width(context),
                height: imageHeight ?? height(context) * 0.25,
              ),
            ),
          ),
        );
      },
    );
  }
}
