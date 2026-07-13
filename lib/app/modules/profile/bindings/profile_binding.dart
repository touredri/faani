import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../controllers/tailor_onboarding_controller.dart';
import '../controllers/tailor_portfolio_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
    Get.lazyPut<TailorOnboardingController>(
      TailorOnboardingController.new,
    );
    Get.lazyPut<TailorPortfolioController>(
      TailorPortfolioController.new,
    );
  }
}
