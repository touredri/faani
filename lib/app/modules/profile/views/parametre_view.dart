import 'package:faani/app/modules/profile/widgets/gerer_compte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import '../../globale_widgets/custom_app_bar.dart';
import '../widgets/change_langue.dart';
import '../widgets/notification_params.dart';

class ParametreView extends GetView {
  const ParametreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: primaryBackAppBar('Paramètre'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            //acount setting
            _Container(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compte',
                    style: TextStyle(color: Colors.grey, fontSize: 14.5),
                  ),
                  3.hs,
                  GestureDetector(
                    onTap: () {
                      Get.to(() => GererCompte(),
                          transition: Transition.downToUp);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              color: Colors.grey,
                            ),
                            2.ws,
                            const Text(
                              'Gerer le compte',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.5),
                            ),
                          ],
                        ),
                        const Icon(Icons.keyboard_arrow_right_rounded)
                      ],
                    ),
                  ),
                  3.hs,
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.privacy_tip_outlined,
                              color: Colors.grey,
                            ),
                            2.ws,
                            const Text(
                              'Privacy',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.5),
                            ),
                          ],
                        ),
                        const Icon(Icons.open_in_new_rounded)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            3.hs, // Contenue & Activité
            _Container(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contenue & Activité',
                    style: TextStyle(color: Colors.grey, fontSize: 14.5),
                  ),
                  3.hs,
                  GestureDetector(
                    onTap: () {
                      Get.to(() => ChangeLanguage(),
                          transition: Transition.downToUp);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language_outlined,
                          color: Colors.grey,
                        ),
                        2.ws,
                        const Text(
                          'Changer de langue',
                          style: TextStyle(color: Colors.black, fontSize: 14.5),
                        ),
                        23.ws,
                        const Text(
                          'Français',
                          style: TextStyle(color: Colors.grey, fontSize: 14.5),
                        )
                      ],
                    ),
                  ),
                  3.hs,
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const NotificationParam(),
                          transition: Transition.downToUp);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_none_outlined,
                              color: Colors.grey,
                            ),
                            2.ws,
                            const Text(
                              'Notifications',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.5),
                            ),
                          ],
                        ),
                        const Icon(Icons.keyboard_arrow_right_rounded)
                      ],
                    ),
                  ),
                  3.hs,
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.grey,
                        ),
                        2.ws,
                        const Text(
                          'Vider le cache',
                          style: TextStyle(color: Colors.black, fontSize: 14.5),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            3.hs,
            // A propos
            _Container(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'A propos de l\'app',
                    style: TextStyle(color: Colors.grey, fontSize: 14.5),
                  ),
                  3.hs,
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              color: Colors.grey,
                            ),
                            2.ws,
                            const Text(
                              'Conditions d\'utilisation',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.5),
                            ),
                          ],
                        ),
                        const Icon(Icons.open_in_new_rounded)
                      ],
                    ),
                  ),
                  3.hs,
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.privacy_tip_outlined,
                              color: Colors.grey,
                            ),
                            2.ws,
                            const Text(
                              'Politique de confidentialité',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.5),
                            ),
                          ],
                        ),
                        const Icon(Icons.open_in_new_rounded)
                      ],
                    ),
                  ),
                  3.hs,
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.privacy_tip_outlined,
                              color: Colors.grey,
                            ),
                            2.ws,
                            const Text(
                              'Open Source Software Notices',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.5),
                            ),
                          ],
                        ),
                        const Icon(Icons.open_in_new_rounded)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            3.hs,
            _Container(
              Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout_outlined,
                          color: Colors.grey,
                        ),
                        2.ws,
                        const Text(
                          'Se déconnecter',
                          style: TextStyle(color: Colors.black, fontSize: 14.5),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _Container(Widget widget) {
  return Container(
    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 20),
    decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10))),
    child: widget,
  );
}
