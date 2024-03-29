import 'package:faani/app/modules/globale_widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../constants/styles.dart';
import '../../home/controllers/user_controller.dart';
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
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomCenter,
                height: MediaQuery.of(context).size.height * 0.94,
                transformAlignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.76,
                  padding: const EdgeInsets.only(
                      left: 7.0, right: 7, top: 55.0, bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
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
                    ],
                  ),
                )),
            Positioned(
              top: 70,
              left: MediaQuery.of(context).size.width * 0.1,
              child:
                  // image et nom d'utilisateur
                  Row(
                children: <Widget>[
                  const SizedBox(
                      width: 125,
                      height: 125,
                      child: BuildProfileImage(width: 125, height: 125)),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // UserController().currentUser.value.nomPrenom!
                      SizedBox(
                        width: 190,
                        child: Text('Drissa Touré',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Colors.white, fontSize: 22)),
                      ),
                      Text(
                        '',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                      ),
                    ],
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
