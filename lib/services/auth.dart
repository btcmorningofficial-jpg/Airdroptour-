import 'package:airdrop/page/home.dart';
import 'package:airdrop/page/loading.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:flutter/material.dart';

class Auth extends ChangeNotifier {
  static TextEditingController email = TextEditingController();
  static TextEditingController password = TextEditingController();
  static TextEditingController name = TextEditingController();
  static void register(BuildContext context) async {
    var x = await ByBugAuth.register(
      email.text,
      password.text,
      language: "tr-Tr",
      name: name.text,
      data: {
        "bio": "",
        "follower": [],
        "cripto": [],
        "social": {},
        "isAdmin": false,
        "status": "active", // active, deactive, ban
        "gender": null,
        "profileCompleted": false,
      },
    );
    if (x[0] == 1) {
      if (!context.mounted) return;
      push(context, LoadingPage());
    } else {
      if (!context.mounted) return;

      getErrorSnack(context, x[1]);
    }
  }

  static void login(BuildContext context) async {
    var x = await ByBugAuth.login(email.text, password.text);
    if (x[0] == 1) {
      if (!context.mounted) return;
      push(context, LoadingPage());
    } else {
      if (!context.mounted) return;

      getErrorSnack(context, x[1]);
    }
  }
}
