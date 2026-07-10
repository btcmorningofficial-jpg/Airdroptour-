import 'package:airdrop/page/home.dart';
import 'package:airdrop/page/loading.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth extends ChangeNotifier {
  static TextEditingController email = TextEditingController();
  static TextEditingController password = TextEditingController();
  static TextEditingController name = TextEditingController();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        '594788456822-dnl6qujce1sp13nalkel4gnjhn5vhtel.apps.googleusercontent.com',
  );

  static void loginWithGoogle(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // kullanıcı iptal etti

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        if (!context.mounted) return;
        getErrorSnack(context, "Google girişi başarısız oldu");
        return;
      }

      var x = await ByBugAuth.loginWithGoogle(idToken);
      if (x[0] == 1) {
        if (!context.mounted) return;
        push(context, LoadingPage());
      } else {
        if (!context.mounted) return;
        getErrorSnack(context, x[1]);
      }
    } catch (e) {
      if (!context.mounted) return;
      getErrorSnack(context, "Google girişi sırasında bir hata oluştu");
    }
  }

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
