import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/suivi_etat_model.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';
import 'package:faani/app/data/services/users_service.dart';

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
  int stepperCurrentIndex = 0;
  String suiviEtatId = '';
  Rx<SuiviEtat?> currentSuiviEtat = Rx<SuiviEtat?>(null);

  void increaseProgress() {
    if (progress < 1) {
      setState(() => progress += 0.2);
    } else {
      setState(() => progress = 0);
    }
  }

  void setStepperCureentIndex(String commandeId) async {
    final suiviEtat =
        await SuiviEtatService().getSuiviEtatByCommandeId(commandeId);
    final etat = await SuiviEtatService().getEtatLibelle(commandeId);
    stepperCurrentIndex = getStepperIndex(etat);
    suiviEtatId = suiviEtat.id;
    currentSuiviEtat.value = suiviEtat;
  }

  // take stepper index from commande etat
  int getStepperIndex(String etat) {
    switch (etat) {
      case 'En cours':
        return 0;
      case 'Decoupes':
        return 1;
      case 'assemblage':
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

  @override
  void initState() {
    super.initState();
    setStepperCureentIndex(widget.commande.id!);
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Column(
      children: [
        EasyStepper(
            activeStep: stepperCurrentIndex,
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
                  if (userController.isTailleur.value)
                    {
                      print(index),
                      if (index == 0)
                        {
                          widget.commande.etatLibelle = 'En cours',
                          widget.commande.update(),
                          currentSuiviEtat.value!.idEtat = '1',
                          currentSuiviEtat.value!.dateModifier =
                              Timestamp.fromDate(DateTime.now()),
                          SuiviEtatService()
                              .updateSuiviEtat(currentSuiviEtat.value!),
                        }
                      else if (index == 1)
                        {
                          widget.commande.etatLibelle = 'Decoupes',
                          widget.commande.update(),
                          currentSuiviEtat.value!.idEtat = '2',
                          currentSuiviEtat.value!.dateModifier =
                              Timestamp.fromDate(DateTime.now()),
                          SuiviEtatService()
                              .updateSuiviEtat(currentSuiviEtat.value!),
                        }
                      else if (index == 2)
                        {
                          widget.commande.etatLibelle = 'assemblage',
                          currentSuiviEtat.value!.idEtat = '3',
                          currentSuiviEtat.value!.dateModifier =
                              Timestamp.fromDate(DateTime.now()),
                          SuiviEtatService()
                              .updateSuiviEtat(currentSuiviEtat.value!),
                        }
                      else if (index == 3)
                        {
                          widget.commande.etatLibelle = 'Paiement',
                          currentSuiviEtat.value!.idEtat = '4',
                          currentSuiviEtat.value!.dateModifier =
                              Timestamp.fromDate(DateTime.now()),
                          SuiviEtatService()
                              .updateSuiviEtat(currentSuiviEtat.value!),
                        }
                      else if (index == 4)
                        {
                          widget.commande.etatLibelle = 'Recuperer',
                          currentSuiviEtat.value!.idEtat = '5',
                          currentSuiviEtat.value!.dateModifier =
                              Timestamp.fromDate(DateTime.now()),
                          SuiviEtatService()
                              .updateSuiviEtat(currentSuiviEtat.value!),
                        }
                      else if (index == 5)
                        {
                          widget.commande.etatLibelle = 'Terminer',
                          currentSuiviEtat.value!.idEtat = '6',
                          currentSuiviEtat.value!.dateModifier =
                              Timestamp.fromDate(DateTime.now()),
                          SuiviEtatService()
                              .updateSuiviEtat(currentSuiviEtat.value!),
                        },
                      setState(() => stepperCurrentIndex = index),
                    },
                }),
      ],
    );
  }
}
