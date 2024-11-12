import 'package:faani/app/modules/authentification/controllers/authentification_controller.dart';
import 'package:faani/app/modules/globale_widgets/animated_pop_up.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/profile/views/privacy.dart';
import 'package:faani/app/modules/profile/widgets/gerer_compte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../globale_widgets/custom_app_bar.dart';
import '../widgets/change_langue.dart';
import '../widgets/notification_params.dart';

class ParametreView extends GetView {
  const ParametreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('Paramètres'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _buildSection(
              title: 'Compte',
              items: [
                _buildItem(
                  icon: Icons.account_circle_outlined,
                  text: 'Gerer le compte',
                  onTap: () => Get.to(() => GererCompte(),
                      transition: Transition.downToUp),
                ),
                _buildItem(
                  icon: Icons.privacy_tip_outlined,
                  text: 'Privacy',
                  onTap: () => Get.to(() => const PrivacyPolicyPage()),
                ),
              ],
            ),
            3.hs,
            _buildSection(
              title: 'Contenue & Activité',
              items: [
                _buildItem(
                  icon: Icons.language_outlined,
                  text: 'Changer de langue',
                  trailingText: 'Français',
                  onTap: () => Get.to(() => const ChangeLanguage(),
                      transition: Transition.downToUp),
                ),
                _buildItem(
                  icon: Icons.notifications_none_outlined,
                  text: 'Notifications',
                  onTap: () => Get.to(() => const NotificationParam(),
                      transition: Transition.downToUp),
                ),
                _buildItem(
                  icon: Icons.delete_forever_outlined,
                  text: 'Vider le cache',
                  onTap: clearCache,
                ),
              ],
            ),
            3.hs,
            _buildSection(
              title: 'A propos de l\'app',
              items: [
                _buildItem(
                  icon: Icons.account_circle_outlined,
                  text: 'Conditions d\'utilisation',
                  onTap: () => AuthController().openUrl(
                      "https://www.freeprivacypolicy.com/live/9a1f28b1-1631-4ce2-b108-716476788cac"),
                ),
                _buildItem(
                  icon: Icons.privacy_tip_outlined,
                  text: 'Politique de confidentialité',
                  onTap: () => AuthController().openUrl(
                      "https://www.freeprivacypolicy.com/live/9a1f28b1-1631-4ce2-b108-716476788cac"),
                ),
                _buildItem(
                  icon: Icons.privacy_tip_outlined,
                  text: 'Open Source Software Notices',
                  onTap: () => AuthController().openUrl(
                      "https://www.freeprivacypolicy.com/live/9a1f28b1-1631-4ce2-b108-716476788cac"),
                ),
              ],
            ),
            3.hs,
            _buildSection(
              title: 'Compte',
              items: [
                _buildItem(
                  icon: Icons.logout_outlined,
                  text: 'Se déconnecter',
                  onTap: () async {
                    animatedPopUp(
                        Get.context!,
                        0.2,
                        0.8,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Attention !!'),
                            3.hs,
                            const Text(
                                textAlign: TextAlign.center,
                                'Êtes-vous sûr de vouloir vous déconnecter ?'),
                            3.hs,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  child: const Text(
                                    'Annuler',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () {
                                    Navigator.of(Get.context!).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Oui, Bien sûr'),
                                  onPressed: () async {
                                    await AuthController().signOut();
                                    // Navigator.of(Get.context!).pop();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> clearCache() async {
    try {
      var tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
      showCustomSnackbar(message: 'Cache vidé avec succès');
    } catch (e) {
      showCustomSnackbar(message: 'Erreur lors de la suppression du cache');
    }
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return _container(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          3.hs,
          ...items.expand((item) => [item, const SizedBox(height: 15)]).toList()
            ..removeLast(),
        ],
      ),
    );
  }

  Widget _buildItem(
      {required IconData icon,
      required String text,
      String? trailingText,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              2.ws,
              Text(text,
                  style: const TextStyle(color: Colors.black, fontSize: 13.5)),
            ],
          ),
          if (trailingText != null)
            Text(trailingText,
                style: const TextStyle(color: Colors.grey, fontSize: 13.5))
          else
            const Icon(Icons.keyboard_arrow_right_rounded),
        ],
      ),
    );
  }
}

Widget _container(Widget widget) {
  return Container(
    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: widget,
  );
}
