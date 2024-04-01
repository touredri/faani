import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:faani/app/modules/profile/views/aide_view.dart';
import 'package:faani/app/modules/profile/views/mes_modeles_view.dart';
import 'package:faani/app/modules/profile/views/parametre_view.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../mesures/views/mesures_view.dart';
import '../views/devenir_tailleur_view.dart';
import '../views/modifier_profile_view.dart';
import 'list_actions.dart';

Widget listBuild(ProfileController controller) {
  return Column(
                    children: [
                      CustomListTile(
                        leadingIcon: Icons.person,
                        title: 'Mon profile',
                        subTitle: 'Changez vos informations',
                        leadingColor: Colors.blue,
                        onTap: () => {
                          Get.to(const ModifierProfileView(),
                              transition: Transition.rightToLeft)
                        },
                      ),
                      CustomListTile(
                          leadingIcon: Icons.location_on,
                          title: 'Mes Mesures',
                          subTitle: 'Voir mes mesures',
                          leadingColor: Colors.green,
                          onTap: () => {
                                Get.to(() => const MesuresView(),
                                    transition: Transition.rightToLeft),
                              }),
                      // if (controller.isTailleur.value)
                      CustomListTile(
                        leadingIcon: Icons.store,
                        title: 'Mes Modèles',
                        subTitle: 'Gerer mes modèles',
                        leadingColor: primaryColor,
                        onTap: () {
                          Get.to(() => const MesModelesView(),
                              transition: Transition.rightToLeft);
                        },
                      ),
                      if (!controller.isTailleur.value)
                        CustomListTile(
                          leadingIcon: Icons.airline_seat_recline_normal,
                          title: 'Devenir Tailleur',
                          subTitle: 'Basculer vers compte tailleur',
                          leadingColor: Colors.red,
                          onTap: () {
                            Get.to(() => DevenirTailleurView(),
                                transition: Transition.rightToLeft);
                          },
                        ),
                      CustomListTile(
                        leadingIcon: Icons.settings,
                        title: 'Paramètres',
                        subTitle: 'Securité, Langue, etc.',
                        leadingColor: Colors.grey,
                        onTap: () {
                          Get.to(() => const ParametreView(),
                              transition: Transition.rightToLeft);
                        },
                      ),
                      CustomListTile(
                        leadingIcon: Icons.help,
                        title: 'Centre d\'aide',
                        subTitle: 'FAQ, Contactez-nous',
                        leadingColor: Colors.blue,
                        onTap: () {
                          Get.to(() => const AideView(),
                              transition: Transition.rightToLeft);
                        },
                      ),
                      CustomListTile(
                        leadingIcon: Icons.send,
                        title: 'Laissez un commentaire',
                        subTitle: 'Comment vous trouvez Faani App',
                        leadingColor: Colors.blueGrey,
                        onTap: () {
                          // Get.to(() => AidePage());
                        },
                      ),
                      CustomListTile(
                        leadingIcon: Icons.star_rate_sharp,
                        title: 'Notez l\'Appli',
                        subTitle: 'Donnez votre avis',
                        leadingColor: Colors.yellow,
                        onTap: () {
                          // Get.to(() => AidePage());
                        },
                      ),
                      CustomListTile(
                        leadingIcon: Icons.share,
                        title: 'Partager Faani App',
                        subTitle: 'Invitez vos amis',
                        leadingColor: Colors.grey,
                        onTap: () {
                          // Get.to(() => AidePage());
                        },
                      ),
                    ],
                  );
}