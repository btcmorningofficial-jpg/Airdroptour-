import 'package:airdrop/widget/sizer.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void getInfoSnack(BuildContext context, String text) {
  showTopSnackBar(Overlay.of(context), CustomSnackBar.info(message: text));
}

void getSuccessSnack(BuildContext context, String text) {
  showTopSnackBar(Overlay.of(context), CustomSnackBar.success(message: text));
}

void getErrorSnack(BuildContext context, String text) {
  showTopSnackBar(Overlay.of(context), CustomSnackBar.error(message: text));
}

void loading(context, {Color? color}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    useSafeArea: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            width: widthSizer(context),
            height: height(context),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

void loadingPop(context) {
  Navigator.pop(context);
}
