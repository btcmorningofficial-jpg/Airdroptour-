import 'package:flutter/material.dart';

class SizerResponsive extends StatelessWidget {
  final Widget child;
  final bool? nonBG;
  const SizerResponsive({super.key, required this.child, this.nonBG});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 505 ? child : mobile(context);
  }

  Widget mobile(BuildContext context) {
    return Scaffold(
      backgroundColor: nonBG == true ? Colors.transparent : Colors.black,
      body: Center(
        child: Container(
          margin: EdgeInsets.all(30),
          width: 450,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                offset: Offset(1, 1),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: child,
          ),
        ),
      ),
    );
  }
}

double widthSizer(BuildContext context) {
  return MediaQuery.sizeOf(context).width < 505
      ? MediaQuery.sizeOf(context).width
      : 450;
}
