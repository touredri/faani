import 'package:faani/app/modules/globale_widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../style/my_theme.dart';
import '../../mesures/views/mesures_view.dart';
import '../controllers/profile_controller.dart';
import '../widgets.dart/list_actions.dart';
import 'aide_view.dart';
import 'devenir_tailleur_view.dart';
import 'mes_modeles_view.dart';
import 'modifier_profile_view.dart';
import 'parametre_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      // backgroundColor: primaryColor,
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              // title: const Text('Drissa Touré'),
              background: Padding(
                padding: EdgeInsets.only(top: 98.0),
                child: SizedBox(
                  width: double.infinity,
                  child: BuildProfileImage(width: 125, height: 125),
                ),
              ),
            ),
          ),
          // SliverPersistentHeader(delegate: SliverPersistentHeaderDelegate()),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // SizedBox(
                //   width: 125,
                //   height: 125,
                //   child: BuildProfileImage(width: 125, height: 125),
                // ),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 73, 144, 192),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomListTile(
                        leadingIcon: Icons.person,
                        title: 'Modifier le profile',
                        leadingColor: Colors.blue,
                        onTap: () => {
                          Get.to(const ModifierProfileView(),
                              transition: Transition.rightToLeft)
                        },
                      ),
                      CustomListTile(
                          leadingIcon: Icons.location_on,
                          title: 'Mes Mesures',
                          leadingColor: Colors.green,
                          onTap: () => {
                                Get.to(() => const MesuresView(),
                                    transition: Transition.rightToLeft),
                              }),
                      // if (controller.isTailleur.value)
                      CustomListTile(
                        leadingIcon: Icons.store,
                        title: 'Mes Modèles',
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
                          leadingColor: Colors.red,
                          onTap: () {
                            Get.to(() => DevenirTailleurView(),
                                transition: Transition.rightToLeft);
                          },
                        ),
                      CustomListTile(
                        leadingIcon: Icons.settings,
                        title: 'Paramètres',
                        leadingColor: Colors.grey,
                        onTap: () {
                          Get.to(() => const ParametreView(),
                              transition: Transition.rightToLeft);
                        },
                      ),
                      CustomListTile(
                        leadingIcon: Icons.help,
                        title: 'Centre d\'aide',
                        leadingColor: Colors.blue,
                        onTap: () {
                          Get.to(() => AideView(),
                              transition: Transition.rightToLeft);
                        },
                      ),
                      // const CustomDivider(), // Séparateur
                      CustomListTile(
                        leadingIcon: Icons.send,
                        title: 'Laissez un commentaire',
                        leadingColor: Colors.blueGrey,
                        onTap: () {
                          // Get.to(() => AidePage());
                        },
                      ),
                      CustomListTile(
                        leadingIcon: Icons.star_rate_sharp,
                        title: 'Notez l\'Appli',
                        leadingColor: Colors.yellow,
                        onTap: () {
                          // Get.to(() => AidePage());
                        },
                      ),
                      CustomListTile(
                        leadingIcon: Icons.share,
                        title: 'Partager Faani App',
                        leadingColor: Colors.grey,
                        onTap: () {
                          // Get.to(() => AidePage());
                        },
                      ),
                      CustomListTile(
                        leadingIcon: Icons.star_rate_sharp,
                        title: 'Notez l\'Appli',
                        leadingColor: Colors.yellow,
                        onTap: () {
                          // Get.to(() => AidePage());
                        },
                      ),
                      CustomListTile(
                        leadingIcon: Icons.share,
                        title: 'Partager Faani App',
                        leadingColor: Colors.grey,
                        onTap: () {
                          // Get.to(() => AidePage());
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
