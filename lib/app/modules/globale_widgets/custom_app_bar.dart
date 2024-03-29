import 'package:faani/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

AppBar primaryBackAppBar(String text) {
  return AppBar(
    backgroundColor: primaryColor,
    leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        )),
    title: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
    elevation: 0,
  );
}
