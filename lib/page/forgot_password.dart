import 'package:airdrop/page/login.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool codeSent = false;
  bool loading = false;

  Future<void> _sendCode() async {
    if (emailController.text.trim().isEmpty) {
      getErrorSnack(context, "Please enter your email");
      return;
    }
    setState(() => loading = true);
    var x = await ByBugAuth.forgotPassword(emailController.text.trim());
    if (!mounted) return;
    setState(() => loading = false);
    if (x[0] == 1) {
      setState(() => codeSent = true);
      getSuccessSnack(context, x[1]);
    } else {
      getErrorSnack(context, x[1]);
    }
  }

  Future<void> _resetPassword() async {
    if (codeController.text.trim().isEmpty ||
        newPasswordController.text.trim().isEmpty) {
      getErrorSnack(context, "Please fill in all fields");
      return;
    }
    setState(() => loading = true);
    var x = await ByBugAuth.resetPassword(
      emailController.text.trim(),
      codeController.text.trim(),
      newPasswordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => loading = false);
    if (x[0] == 1) {
      getSuccessSnack(context, "Password updated. You can now log in.");
      push(context, LoginPage());
    } else {
      getErrorSnack(context, x[1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40),
                h1("Reset Password"),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: subP(
                    codeSent
                        ? "Enter the 6-digit code we sent to your email, along with your new password."
                        : "Enter your account email. We'll send you a code to reset your password.",
                  ),
                ),
                SizedBox(height: 30),
                textfield(
                  text: "E-mail",
                  textController: emailController,
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                ),
                if (codeSent) ...[
                  textfield(
                    text: "6-digit code",
                    textController: codeController,
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                  ),
                  textfield(
                    text: "New Password",
                    textController: newPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    obscureText: true,
                  ),
                ],
                SizedBox(height: 10),
                GestureDetector(
                  onTap: loading
                      ? null
                      : (codeSent ? _resetPassword : _sendCode),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    width: widthSizer(context),
                    decoration: BoxDecoration(
                      color: defaultColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: h5(
                        loading
                            ? "Please wait..."
                            : (codeSent ? "Reset Password" : "Send Code"),
                      ),
                    ),
                  ),
                ),
                if (codeSent)
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            setState(() {
                              codeSent = false;
                              codeController.clear();
                              newPasswordController.clear();
                            });
                          },
                    child: p("Use a different email"),
                  ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
