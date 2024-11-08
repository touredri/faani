import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:upgrader/upgrader.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    Get.put(UserController());
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.cupertino,
      upgrader: Upgrader(messages: UpgraderMessages(code: 'fr')),
      child: Scaffold(
        body: PersistentTabView(
          controller: controller.tabController,
          backgroundColor: scaffoldBack!,
          tabs: controller.tabs(),
          navBarBuilder: (navBarConfig) => Style13BottomNavBar(
            navBarDecoration: const NavBarDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0)),
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            ),
            navBarConfig: navBarConfig,
          ),
        ),
      ),
    );
  }
}
