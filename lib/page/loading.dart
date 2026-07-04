import 'package:airdrop/page/home.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await MyProfileData.getMyProfile();
      if (MyProfileData.status() == "active") {
        await Future.delayed(Durations.extralong4);
        if (!mounted) return;
        push(context, HomePage());
      } else if (MyProfileData.status() == "deactive") {
        if (!mounted) return;
        CosmosAlert.showIOSStyleAlert(
          context,
          "Your Account Has Been Deactivated!",
          "Your account has been disabled by the administrators.",
        );
      } else if (MyProfileData.status() == "ban") {
        if (!mounted) return;
        CosmosAlert.showIOSStyleAlert(
          context,
          "Your Account Has Been Banned",
          "Your account has been banned by the administrators.",
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: AirdroptourImage(
                "assets/logo.jpg",
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(height: 80),
            CupertinoActivityIndicator(color: textColor, radius: 14),
          ],
        ),
      ),
    );
  }
}
