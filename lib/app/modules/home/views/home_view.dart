import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:upgrader/upgrader.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!(controller.fcmInitialized ?? false)) {
      controller.fcmInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.pushNotifications.initializeFCM(context);
      });
    }

    final theme = Theme.of(context);

    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.cupertino,
      upgrader: Upgrader(
        messages: UpgraderMessages(code: 'fr'),
        durationUntilAlertAgain: const Duration(days: 1),
      ),
      child: Scaffold(
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            controller.canPop();
          },
          child: PersistentTabView(
            controller: controller.tabController,
            backgroundColor: theme.scaffoldBackgroundColor,
            tabs: controller.tabs(),
            navBarBuilder: (navBarConfig) => Style15BottomNavBar(
              navBarDecoration: const NavBarDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  topRight: Radius.circular(AppRadius.xl),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.xs,
                ),
              ),
              navBarConfig: navBarConfig,
            ),
          ),
        ),
      ),
    );
  }
}
