import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/suivi_etat_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/widgets/build_time_line.dart';
import 'package:faani/app/modules/commande/widgets/image_pop_up.dart';
import 'package:faani/app/modules/commande/widgets/stepper.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../widgets/expand_image.dart';

class DetailCommandeView extends GetView<CommandeController> {
  final Commande commande;
  const DetailCommandeView(this.commande, {super.key});
  @override
  Widget build(BuildContext context) {
    final CommandeController controller = Get.put(CommandeController());
    final String imageUrl = getRandomProfileImageUrl();
    final UserController userController = Get.find();
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: primaryColor,
        ),
        body: FutureBuilder(
            future: controller.fetchCommandeData(commande),
            builder: (context, result) {
              if (result.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (result.hasError) {
                return Text('Error2: ${result.error}');
              } else {
                Modele modele = result.data![2] as Modele;
                UserModel tailleur = result.data![0] as UserModel;
                UserModel? client = result.data![1] != null
                    ? result.data![1] as UserModel
                    : null;
                SuiviEtat etat = result.data![3];
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.26,
                              child: DisplayImage(modele: modele)),
                          Container(
                            alignment: Alignment.bottomCenter,
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.2,
                            ),
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.remove_red_eye_outlined),
                              onPressed: () {
                                imagePopUp(
                                    context: context,
                                    imageUrl: modele.fichier[0]!,
                                    onButtonPressed: () {
                                      Get.back();
                                    },
                                    size: MediaQuery.of(context).size.height *
                                        0.8,
                                    buttonText: '',
                                    isHaveAction: false);
                              },
                              label: const Text('voir'),
                            ),
                          )
                        ],
                      ),
                      0.8.hs,
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 5),
                          leading: CircleAvatar(
                            radius: 25,
                            child: Image.network(imageUrl),
                          ),
                          title: Text(
                            controller.userController.isTailleur.value
                                ? commande.nomClient
                                : tailleur.nomPrenom!,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                              controller.userController.isTailleur.value
                                  ? commande.numeroClient.toString()
                                  : 'Couture ${tailleur.clientCible!}',
                              style: TextStyle(
                                fontSize: 13,
                              )),
                          trailing: TextButton.icon(
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(
                                  const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.grey,
                              ),
                              label: const Text(
                                'Valider',
                                style: TextStyle(color: Colors.grey),
                              )),
                        ),
                      ),
                      Stack(
                        children: [
                          const MyStep(),
                          Padding(
                            padding: const EdgeInsets.only(top: 65.0),
                            child: Column(
                              children: [
                                TimelineTile(
                                  alignment: TimelineAlign.manual,
                                  lineXY: 0.4,
                                  isFirst: true,
                                  indicatorStyle: const IndicatorStyle(
                                    width: 60,
                                    height: 60,
                                    indicator: IconIndicator(
                                      iconData: Icons.info,
                                    ),
                                  ),
                                  beforeLineStyle: LineStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                  startChild: const SizedBox(
                                    height: 80,
                                    width: 80,
                                  ),
                                  endChild: const Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: Text('Autre détails',
                                        style: TextStyle(
                                          fontSize: 13,
                                        )),
                                  ),
                                ),
                                buildTimelineTile(
                                    title: 'Photo de l\'habit',
                                    indicator: const IconIndicator(
                                      iconData: Icons.photo,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        imagePopUp(
                                            context: context,
                                            imageUrl: imageUrl,
                                            onButtonPressed: () {
                                              Get.back();
                                            },
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.45,
                                            buttonText: 'Change Image 🔄',
                                            isHaveAction: true);
                                      },
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        height: 80,
                                        child: Image.asset(
                                          'assets/images/ic_launcher.png',
                                          fit: BoxFit.cover,
                                          width: 90,
                                        ),
                                      ),
                                    )),
                                buildTimelineTile(
                                    title: 'Date prevue',
                                    indicator: const IconIndicator(
                                      iconData: Icons.date_range,
                                    ),
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      height: 90,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              commande.datePrevue
                                                  .toString()
                                                  .split(' ')[0],
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            1.ws,
                                            IconButton(
                                                onPressed: () {},
                                                icon: const Icon(Icons
                                                    .edit_calendar_outlined))
                                          ],
                                        ),
                                      ),
                                    )),
                                buildTimelineTile(
                                    title: 'Mésure',
                                    indicator: const IconIndicator(
                                      iconData: Icons.straighten,
                                    ),
                                    isLast: true,
                                    child: SizedBox(
                                        height: 35,
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Voir les mésures',
                                              style: TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            1.ws,
                                            IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                    Icons.open_in_new))
                                          ],
                                        ))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      6.5.hs,
                      // price info & icon message
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 5),
                          leading: const Icon(
                            Icons.monetization_on,
                            color: Colors.grey,
                          ),
                          title: Text('Prix: ${commande.prix} FCFA',
                              style: const TextStyle(fontSize: 16)),
                          subtitle: const Text(
                            'Avance: 0 FCFA',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          trailing: TextButton.icon(
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(
                                  const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.message_outlined,
                                color: Colors.grey,
                              ),
                              label: const Text(
                                'Discuter',
                                style: TextStyle(color: Colors.grey),
                              )),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }));
  }
}
