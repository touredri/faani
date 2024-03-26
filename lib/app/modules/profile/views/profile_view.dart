import 'package:faani/app/modules/globale_widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../constants/styles.dart';
import '../../mesures/views/mesures_view.dart';
import '../controllers/profile_controller.dart';
import '../widgets.dart/list_actions.dart';
import 'modifier_profile_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      left: 7.0, right: 7, top: 35.0, bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
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
                        const CustomDivider(),
                        CustomListTile(
                            leadingIcon: Icons.location_on,
                            title: 'Mes Mesures',
                            leadingColor: Colors.green,
                            onTap: () => {
                                  Get.to(() => const MesuresView()),
                                }),
                        const CustomDivider(),
                        CustomListTile(
                          leadingIcon: Icons.store,
                          title: 'Mes Modèles',
                          leadingColor: primaryColor,
                          onTap: () {
                            // Get.toNamed(Routes.BOUTIQUE, arguments: 1);
                          },
                        ),
                        const CustomDivider(),
                        CustomListTile(
                          leadingIcon: Icons.favorite,
                          title: 'Devenir Tailleur',
                          leadingColor: Colors.red,
                          onTap: () {
                            // Get.to(() => const FavoriePage());
                          },
                        ),
                        const CustomDivider(), // Séparateur
                        CustomListTile(
                          leadingIcon: Icons.settings,
                          title: 'Paramètres',
                          leadingColor: Colors.purple,
                          onTap: () {
                            // Get.to(() => const ParametreView());
                          },
                        ),
                        const CustomDivider(), // Séparateur
                        CustomListTile(
                          leadingIcon: Icons.help,
                          title: 'Centre d\'aide',
                          leadingColor: Colors.blue,
                          onTap: () {
                            // Get.to(() => AidePage());
                          },
                        ),
                        const CustomDivider(), // Séparateur
                        CustomListTile(
                          leadingIcon: Icons.star_rate_sharp,
                          title: 'Laissez un commentaire',
                          leadingColor: Colors.yellow,
                          onTap: () {
                            // Get.to(() => AidePage());
                          },
                        ),
                        const CustomDivider(), // Séparateur
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
                  ),
                )),
            Positioned(
              top: 50,
              left: MediaQuery.of(context).size.width * 0.1,
              child:
                  // image et nom d'utilisateur
                  Row(
                children: <Widget>[
                  // const SizedBox(width: 20),
                  const SizedBox(
                      width: 125,
                      height: 125,
                      child: BuildProfileImage(width: 100, height: 100)),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // UserController().currentUser.value.nomPrenom!
                      Text('DRISSA TOURE',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white)),
                      Text(
                        '+223 63 63 63 63',
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
