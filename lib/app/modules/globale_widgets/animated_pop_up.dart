import 'package:flutter/material.dart';

Future<void> animatedPopUp(BuildContext context, double height, double width, Widget child) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(5),
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * height,
          width: MediaQuery.of(context).size.width * width,
          child: child,
        ),
      );
    },
    transitionBuilder: (BuildContext context, Animation animation,
        Animation secondaryAnimation, Widget child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation as Animation<double>,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
}