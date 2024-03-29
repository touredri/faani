import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ChangeLanguage extends GetView<ProfileController> {
  ChangeLanguage({super.key});
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: primaryBackAppBar('Paramète de langue'),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text(
              'Français',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            trailing: Obx(() => controller.selectedLanguage.value == 'Français'
                ? const Icon(Icons.check)
                : const SizedBox.shrink()),
            onTap: () => controller.updateLanguage('Français'),
          ),
          ListTile(
            title: const Text(
              'Anglais',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            trailing: Obx(() => controller.selectedLanguage.value == 'Anglais'
                ? const Icon(Icons.check)
                : const SizedBox.shrink()),
            onTap: () {
              controller.updateLanguage('Anglais');
              Get.updateLocale(
                  const Locale('pt', 'BR')); // Change la langue Français
            },
          ),
          const Divider(),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(left: 5),
            height: 300,
            child: ListView.builder(
              itemCount: controller.languages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    controller.languages[index],
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  trailing: Obx(() => controller.selectedLanguage.value ==
                          controller.languages[index]
                      ? const Icon(Icons.check)
                      : const SizedBox.shrink()),
                  onTap: () =>
                      controller.updateLanguage(controller.languages[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          ElevatedButton(onPressed: () {}, child: Text('Sauvergarder')),
    );
  }
}
