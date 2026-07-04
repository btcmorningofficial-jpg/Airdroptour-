import 'package:airdrop/page/register.dart';
import 'package:airdrop/services/auth.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            Spacer(),
            h1("Airdroptour"),
            SizedBox(height: 20),
            textfield(
              text: "E-mail",
              textController: Auth.email,
              keyboardType: TextInputType.emailAddress,
            ),
            textfield(
              text: "Password",
              textController: Auth.password,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            SizedBox(height: 10),
            subP("By logging in you agree to our policies."),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => Auth.login(context),
              child: Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                width: widthSizer(context),
                decoration: BoxDecoration(
                  color: defaultColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: h5("Login")),
              ),
            ),
            GestureDetector(
              onTap: () {
                push(context, RegisterPage());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: p("Don't have an account? Sign up."),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
