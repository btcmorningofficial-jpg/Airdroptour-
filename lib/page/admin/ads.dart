import 'package:airdrop/services/admin.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:flutter/material.dart';

class AdminADS extends StatefulWidget {
  const AdminADS({super.key});

  @override
  State<AdminADS> createState() => _AdminADSState();
}

class _AdminADSState extends State<AdminADS> {
  @override
  void initState() {
    super.initState();
    AdminServices.getAdsAdmin(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AdminServices.adsAdmin]),
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  AdminServices.addAds(context);
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
                      children: [bold("Add New Banner")],
                    ),
                  ),
                ),
              ),

              Column(children: AdminServices.adsAdmin.value),
              SizedBox(height: 66),
            ],
          ),
        );
      },
    );
  }
}
