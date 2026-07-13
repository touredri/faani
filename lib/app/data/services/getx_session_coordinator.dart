import 'package:faani/app/data/services/session_coordinator.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/favorie/controllers/favorie_controller.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:faani/app/modules/profile/controllers/tailor_onboarding_controller.dart';
import 'package:faani/app/modules/profile/controllers/tailor_portfolio_controller.dart';
import 'package:get/get.dart';

class GetxSessionCoordinator extends ActionSessionCoordinator {
  GetxSessionCoordinator(super.actions);

  factory GetxSessionCoordinator.standard() {
    return GetxSessionCoordinator([
      _getxAction<ProfileController>('ProfileController'),
      _getxAction<TailorOnboardingController>('TailorOnboardingController'),
      _getxAction<TailorPortfolioController>('TailorPortfolioController'),
      _getxAction<CommandeController>('CommandeController'),
      _getxAction<FavorieController>('FavorieController'),
      _getxAction<AccueilController>('AccueilController'),
      _getxAction<HomeController>('HomeController'),
      _getxAction<UserController>('UserController'),
    ]);
  }

  static SessionCleanupAction _getxAction<T>(String name) {
    return SessionCleanupAction(
      name: name,
      isRegistered: Get.isRegistered<T>,
      dispose: () => Get.delete<T>(force: true),
    );
  }
}
