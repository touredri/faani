import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:faani/app/routes/app_pages.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<HomeController>()) {
      return const RouteSettings(name: Routes.PROFILE);
    }

    final homeController = Get.find<HomeController>();
    if (homeController.isAdmin.value) {
      return null;
    }

    return const RouteSettings(name: Routes.PROFILE);
  }
}
