import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/suivi_etat_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';

class MyStep extends StatefulWidget {
  final Commande commande;
  const MyStep({super.key, required this.commande});

  @override
  State<MyStep> createState() => _MyStepState();
}

class _MyStepState extends State<MyStep> {
  int activeStep = 0;
  int activeStep2 = 0;
  int reachedStep = 0;
  int upperBound = 5;
  double progress = 0.2;
  RxInt stepperCurrentIndex = 0.obs;
  Rx<SuiviEtat?> currentSuiviEtat = Rx<SuiviEtat?>(null);

  void increaseProgress() {
    if (progress < 1) {
      setState(() => progress += 0.2);
    } else {
      setState(() => progress = 0);
    }
  }

  Future<void> setStepperCureentIndex(String commandeId) async {
    final suiviEtat =
        await SuiviEtatService().getSuiviEtatByCommandeId(commandeId);
    final etat = await SuiviEtatService().getEtatLibelle(commandeId);
    stepperCurrentIndex.value = getStepperIndex(etat);
    currentSuiviEtat.value = suiviEtat;
  }

  // take stepper index from commande etat
  int getStepperIndex(String etat) {
    switch (etat) {
      case 'En cours':
        return 0;
      case 'Decoupes':
        return 1;
      case 'Assemblage':
        return 2;
      case 'Paiement':
        return 3;
      case 'Recuperer':
        return 4;
      case 'Terminer':
        return 5;
      default:
        return 0;
    }
  }

  void updateCommande() async {
    await widget.commande.update();
  }

  void sendNotif() async {
    if (widget.commande.idUser.isNotEmpty) {
      final UserModel client =
          await UserService().getUser(widget.commande.idUser);
      await sendNotification(client.token!, 'Etat Commande modifié',
          'L\etat de votre commande a été modifiée par le tailleur à ${widget.commande.etatLibelle}');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return FutureBuilder<void>(
        future: setStepperCureentIndex(widget.commande.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Column(
              children: [
                EasyStepper(
                    activeStep: stepperCurrentIndex.value,
                    stepRadius: 25,
                    lineStyle: LineStyle(
                      lineLength: 75,
                      lineSpace: 4,
                      lineType: LineType.normal,
                      unreachedLineColor: Colors.grey.withOpacity(0.5),
                      finishedLineColor: Colors.deepOrange,
                      activeLineColor: Colors.grey.withOpacity(0.5),
                    ),
                    borderThickness: 10,
                    internalPadding: 10,
                    steps: const [
                      EasyStep(
                        icon: Icon(Icons.info),
                        lineText: 'Decoupes',
                      ),
                      EasyStep(
                        icon: Icon(Icons.cut),
                        lineText: 'assemblage',
                      ),
                      EasyStep(
                        icon: Icon(Icons.man_2),
                        lineText: 'Paiement',
                      ),
                      EasyStep(
                        icon: Icon(CupertinoIcons.money_dollar),
                        lineText: 'Recuperer',
                      ),
                      EasyStep(
                        icon: Icon(Icons.file_present_rounded),
                        lineText: 'Terminer',
                      ),
                      EasyStep(
                        icon: Icon(Icons.check_circle_outline),
                      ),
                    ],
                    onStepReached: (index) => {
                          if (userController.isTailleur.value &&
                              widget.commande.idTailleur ==
                                  userController.currentUser.value.id)
                            {
                              if (index == 0)
                                {
                                  widget.commande.etatLibelle = 'En cours',
                                  currentSuiviEtat.value!.idEtat = '1',
                                }
                              else if (index == 1)
                                {
                                  widget.commande.etatLibelle = 'Decoupes',
                                  currentSuiviEtat.value!.idEtat = '2',
                                }
                              else if (index == 2)
                                {
                                  widget.commande.etatLibelle = 'assemblage',
                                  currentSuiviEtat.value!.idEtat = '3',
                                }
                              else if (index == 3)
                                {
                                  widget.commande.etatLibelle = 'Paiement',
                                  currentSuiviEtat.value!.idEtat = '4',
                                }
                              else if (index == 4)
                                {
                                  widget.commande.etatLibelle = 'Recuperer',
                                  currentSuiviEtat.value!.idEtat = '5',
                                }
                              else if (index == 5)
                                {
                                  widget.commande.etatLibelle = 'Terminer',
                                  currentSuiviEtat.value!.idEtat = '6',
                                },
                              currentSuiviEtat.value!.dateModifier =
                                  Timestamp.fromDate(DateTime.now()),
                              SuiviEtatService()
                                  .updateSuiviEtat(currentSuiviEtat.value!),
                              updateCommande(),
                              sendNotif(),
                              setState(() => stepperCurrentIndex.value = index),
                            },
                        }),
              ],
            );
          }
        });
  }
}
