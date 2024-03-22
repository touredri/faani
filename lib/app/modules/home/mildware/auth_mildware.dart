import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../firebase/global_function.dart';
import '../../../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (auth.currentUser != null) {
      return null;
    }
    return const RouteSettings(name: Routes.AUTH);
  }
}
