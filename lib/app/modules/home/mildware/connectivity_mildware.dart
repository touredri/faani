import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetConnectivityMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final homeController = Get.find<HomeController>();
    homeController.checkInternetConnectivity();
    return super.redirect(route);
  }
}

class InternetConnectivityMiddlewareWithRedirect extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final homeController = Get.find<HomeController>();
    homeController.checkInternetConnectivity();
    if (!homeController.isOnline.value) {
      return const RouteSettings(name: '/');
    }
    return super.redirect(route);
  }
}