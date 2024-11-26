import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';

class UpgraderController extends GetxController {
  final upgrader = Upgrader(
    debugLogging: true,
    countryCode: 'fr',
    languageCode: 'fr',
    storeController: UpgraderStoreController(),
    durationUntilAlertAgain: const Duration(days: 1),
    willDisplayUpgrade: ({required bool display, String? installedVersion, UpgraderVersionInfo? versionInfo}) {
    },
  );

  @override
  void onInit() {
    upgrader;
    super.onInit();
  }
}
