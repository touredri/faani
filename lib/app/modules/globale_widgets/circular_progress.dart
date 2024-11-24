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
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration,
    ),
  );
}
