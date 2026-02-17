import 'package:flutter/material.dart';
import 'package:get/get.dart';

SizedBox circularProgress({Color color = Colors.white}) {
  return SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color),
    ),
  );
}

void showCustomSnackbar({
  required String message,
  Color backgroundColor = Colors.red,
  Duration duration = const Duration(seconds: 3),
}) {
  final context = Get.overlayContext ?? Get.context;
  if (context == null) {
    debugPrint('showCustomSnackbar skipped: no active overlay context');
    return;
  }

  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    debugPrint('showCustomSnackbar skipped: no ScaffoldMessenger found');
    return;
  }

  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration,
    ),
  );
}
