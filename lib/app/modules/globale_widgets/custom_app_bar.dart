import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

AppBar primaryBackAppBar(String text) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: AppColors.primary,
    leading: IconButton(
      onPressed: () => Get.back(),
      icon: const Icon(Icons.arrow_back, color: AppColors.white),
    ),
    title: Text(
      text,
      style: AppTypography.headlineSmall.copyWith(color: AppColors.white),
    ),
    elevation: 0,
  );
}

AppBar customAppBar(String text) {
  return AppBar(
    title: Text(text),
    centerTitle: true,
  );
}
