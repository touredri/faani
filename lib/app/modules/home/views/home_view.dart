import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:upgrader/upgrader.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  late HomeController controller;
  late PersistentTabController tabController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
    tabController = PersistentTabController(initialIndex: 0);
    BackButtonInterceptor.add(myInterceptor);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.pushNotifications.initializeFCM(context);
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (tabController.index != 0) {
      tabController.jumpToTab(0);
      print(
          'Back button intercepted and tab changed to ${tabController.index}');
      return true;
    }
    print('Back button intercepted and tab is already at 0');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.cupertino,
      upgrader: Upgrader(messages: UpgraderMessages(code: 'fr')),
      child: Scaffold(
        body: PersistentTabView(
          controller: tabController,
          backgroundColor: scaffoldBack!,
          tabs: controller.tabs(),
          navBarBuilder: (navBarConfig) => Style15BottomNavBar(
            navBarDecoration: const NavBarDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0)),
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            ),
            navBarConfig: navBarConfig,
          ),
        ),
      ),
    );
  }
}
