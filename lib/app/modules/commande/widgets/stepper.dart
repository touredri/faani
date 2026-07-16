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
  late Future<void> _trackingFuture;

  void increaseProgress() {
    if (progress < 1) {
      setState(() => progress += 0.2);
    } else {
      setState(() => progress = 0);
    }
  }

  Future<void> setStepperCureentIndex(String commandeId) async {
    try {
      final suiviEtat =
          await SuiviEtatService().getSuiviEtatByCommandeId(commandeId);
      final etat = await SuiviEtatService().getEtatLibelle(commandeId);
      stepperCurrentIndex.value = getStepperIndex(etat);
      currentSuiviEtat.value = suiviEtat;
    } catch (_) {
      // Les commandes historiques peuvent ne pas avoir de suivi associé.
      stepperCurrentIndex.value = getStepperIndex(widget.commande.etatLibelle);
    }
  }

  // take stepper index from commande etat
  int getStepperIndex(String etat) {
    switch (etat.trim().toLowerCase()) {
      case 'en cours':
        return 0;
      case 'decoupes':
        return 1;
      case 'assemblage':
        return 2;
      case 'paiement':
        return 3;
      case 'recuperer':
        return 4;
      case 'terminer':
        return 5;
      default:
        return 0;
    }
  }

  Future<void> updateCommande() {
    return widget.commande.update();
  }

  Future<void> sendNotif() async {
    if (widget.commande.idUser.isNotEmpty) {
      final UserModel client =
          await UserService().getUser(widget.commande.idUser);
      final token = client.token;
      if (token == null || token.isEmpty) return;
      await sendNotification(
        token,
        'Etat Commande modifié',
        'L’état de votre commande a été modifié par le tailleur : ${widget.commande.etatLibelle}',
        category: 'order',
        targetType: 'commande',
        targetId: widget.commande.id ?? '',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _trackingFuture = setStepperCureentIndex(widget.commande.id!);
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return FutureBuilder<void>(
        future: _trackingFuture,
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
                      unreachedLineColor: Colors.grey.withValues(alpha: 0.5),
                      finishedLineColor: Colors.deepOrange,
                      activeLineColor: Colors.grey.withValues(alpha: 0.5),
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
                    onStepReached: (index) async {
                      if (!userController.isTailleur.value ||
                          widget.commande.idTailleur !=
                              userController.currentUser.value.id ||
                          currentSuiviEtat.value == null) {
                        return;
                      }

                      const labels = [
                        'En cours',
                        'Decoupes',
                        'Assemblage',
                        'Paiement',
                        'Recuperer',
                        'Terminer',
                      ];
                      widget.commande.etatLibelle = labels[index];
                      currentSuiviEtat.value!.idEtat = '${index + 1}';
                      currentSuiviEtat.value!.dateModifier =
                          Timestamp.fromDate(DateTime.now());
                      await SuiviEtatService()
                          .updateSuiviEtat(currentSuiviEtat.value!);
                      await updateCommande();
                      await sendNotif();
                      if (mounted) {
                        setState(() => stepperCurrentIndex.value = index);
                      }
                    }),
              ],
            );
          }
        });
  }
}
