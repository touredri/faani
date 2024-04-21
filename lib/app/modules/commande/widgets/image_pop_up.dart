import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Future imagePopUp(
    {required BuildContext context,
    required String imageUrl,
    required VoidCallback onButtonPressed,
    required double size,
    required String buttonText,
    required bool isHaveAction}) {
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
        insetPadding: const EdgeInsets.all(10),
        content: SizedBox(
          height: size,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
        actions: isHaveAction
            ? [
                TextButton(
                  onPressed: onButtonPressed,
                  child: Text(buttonText),
                ),
              ]
            : null,
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

Future successDialog(
    {required BuildContext context,
    required String successMessage,
    required VoidCallback onButtonPressed}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return AlertDialog(
        content: Text(successMessage),
        actions: [
          TextButton(
            onPressed: onButtonPressed,
            child: const Text('OK'),
          ),
        ],
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