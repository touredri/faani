import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_colors.dart';
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
        extendBody: true,
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
              navBarDecoration: NavBarDecoration(
                color: navBarConfig.selectedIndex == 0
                    ? Colors.transparent
                    : theme.scaffoldBackgroundColor,
                borderRadius: navBarConfig.selectedIndex == 0
                    ? BorderRadius.circular(AppRadius.full)
                    : const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.xl),
                        topRight: Radius.circular(AppRadius.xl),
                      ),
                padding: EdgeInsets.symmetric(
                  horizontal: navBarConfig.selectedIndex == 0
                      ? AppSpacing.lg
                      : AppSpacing.sm,
                  vertical: navBarConfig.selectedIndex == 0
                      ? AppSpacing.xxs
                      : AppSpacing.xs,
                ),
                boxShadow: navBarConfig.selectedIndex == 0
                    ? [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.22),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              navBarConfig: navBarConfig,
            ),
          ),
        ),
      ),
    );
  }
}
