import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
  final HomeController controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) => PersistentTabView(
        controller: controller.tabController,
        backgroundColor: scaffoldBack!,
        tabs: controller.tabs(),
        navBarBuilder: (navBarConfig) => Style6BottomNavBar(
          navBarDecoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(20.0),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          ),
          navBarConfig: navBarConfig,
        ),
      );
}
