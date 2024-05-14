import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/widgets/build_time_line.dart';
import 'package:faani/app/modules/commande/widgets/image_pop_up.dart';
import 'package:faani/app/modules/commande/widgets/stepper.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/message/controllers/message_controller.dart';
import 'package:faani/app/modules/mesures/views/detail_mesure.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class DetailCommandeView extends GetView<CommandeController> {
  final Commande commande;
  const DetailCommandeView(this.commande, {super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(CommandeController());
    const String imageUrl = 'https://robohash.org/98';
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
                // SuiviEtat etat = result.data![3];
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
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.remove_red_eye_outlined,
                                color: Colors.white,
                              ),
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
                            child: imageCacheNetwork(
                                context,
                                controller.userController.isTailleur.value
                                    ? client?.profileImage ?? imageUrl
                                    : tailleur.profileImage!),
                          ),
                          title: Text(
                            controller.userController.isTailleur.value
                                ? commande.nomClient
                                : tailleur.nomPrenom!,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                              controller.userController.isTailleur.value
                                  ? commande.numeroClient.toString()
                                  : 'Couture ${tailleur.clientCible!}',
                              style: const TextStyle(
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
                              onPressed: () async {
                                controller.acceptCommande(commande);
                              },
                              icon: Icon(
                                Icons.check_circle_outline,
                                color: commande.isAccepted
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              label: GetBuilder<CommandeController>(
                                init: CommandeController(),
                                initState: (_) {},
                                builder: (_) {
                                  return Text(
                                    commande.isAccepted
                                        ? 'Accepter'
                                        : !controller
                                                .userController.isTailleur.value
                                            ? 'En attente'
                                            : 'Accepté',
                                    style: TextStyle(
                                        color: commande.isAccepted
                                            ? Colors.green
                                            : Colors.grey),
                                  );
                                },
                              )),
                        ),
                      ),
                      Stack(
                        children: [
                          MyStep(
                            commande: commande,
                          ),
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
                                            imageUrl: commande.photoHabit != ''
                                                ? commande.photoHabit
                                                : imageUrl,
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
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(
                                            commande.photoHabit,
                                            fit: BoxFit.cover,
                                            height: double.infinity,
                                            width: 90,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                          ),
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
                                            GetBuilder<CommandeController>(
                                              init: CommandeController(),
                                              initState: (_) {},
                                              builder: (_) {
                                                return SizedBox(
                                                  width: 130.sp,
                                                  child: Text(
                                                    DateFormat('EEEE d MMMM y',
                                                            'fr_FR')
                                                        .format(
                                                            commande.datePrevue)
                                                        .toString(),
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            1.ws,
                                            IconButton(
                                                onPressed: () {
                                                  controller.changeDate(
                                                      commande,
                                                      context: context);
                                                },
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
                                                onPressed: () {
                                                  Get.to(() => DetailMesure(
                                                        id: commande.idMesure,
                                                      ));
                                                },
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
                          leading: IconButton(
                              padding: const EdgeInsets.all(0),
                              onPressed: () {
                                controller.changePrice(commande,
                                    context: context);
                              },
                              icon: Icon(
                                commande.prix != 0 &&
                                        !userController.isTailleur.value
                                    ? Icons.monetization_on
                                    : Icons.edit,
                                color: Colors.grey,
                              )),
                          title: GetBuilder<CommandeController>(
                            init: CommandeController(),
                            initState: (_) {},
                            builder: (_) {
                              return Text('Prix: ${commande.prix} FCFA',
                                  style: const TextStyle(fontSize: 15));
                            },
                          ),
                          subtitle: const Text(
                            'Avance: 0 FCFA',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
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
                              onPressed: () {
                                if (commande.isSelfAdded) {
                                  Get.snackbar('Erreur',
                                      'Vous ne pouvez pas discuter avec vous même',
                                      snackPosition: SnackPosition.BOTTOM);
                                } else {
                                  MessageController().goChat(tailleur,
                                      modeleImg: modele.fichier[0]!);
                                }
                              },
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
