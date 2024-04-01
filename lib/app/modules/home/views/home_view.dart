import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  final HomeController controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) => PersistentTabView(
        controller: controller.tabController,
        backgroundColor: scaffoldBack!,
        tabs: controller.tabs(),
        navBarBuilder: (navBarConfig) => Style6BottomNavBar(
          navBarDecoration: const NavBarDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          ),
          navBarConfig: navBarConfig,
        ),
      );
}
