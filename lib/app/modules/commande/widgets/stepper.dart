import 'package:easy_stepper/easy_stepper.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyStep extends StatefulWidget {
  const MyStep({Key? key}) : super(key: key);

  @override
  State<MyStep> createState() => _MyStepState();
}

class _MyStepState extends State<MyStep> {
  int activeStep = 0;
  int activeStep2 = 0;
  int reachedStep = 0;
  int upperBound = 5;
  double progress = 0.2;
  // Set<int> reachedSteps = <int>{0, 2, 4, 5};
  // final dashImages = [
  //   'assets/1.png',
  //   'assets/2.png',
  //   'assets/3.png',
  //   'assets/4.png',
  //   'assets/5.png',
  // ];

  void increaseProgress() {
    if (progress < 1) {
      setState(() => progress += 0.2);
    } else {
      setState(() => progress = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Column(
      children: [
        EasyStepper(
            activeStep: activeStep,
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
                title: 'En cours',
                lineText: 'Met en Decoupes',
              ),
              EasyStep(
                icon: Icon(Icons.cut),
                title: 'Decoupes',
                lineText: 'Vas en assemblage',
              ),
              EasyStep(
                icon: Icon(Icons.man_2),
                title: 'Assemblage',
                lineText: 'Reste du paiement',
              ),
              EasyStep(
                icon: Icon(CupertinoIcons.money_dollar),
                title: 'Payment',
                lineText: 'Recuperation',
              ),
              EasyStep(
                icon: Icon(Icons.file_present_rounded),
                title: 'Livraison',
                lineText: 'Marché conclu',
              ),
              EasyStep(
                icon: Icon(Icons.check_circle_outline),
                title: 'Terminé',
              ),
            ],
            onStepReached: (index) => {
                  if (userController.isTailleur.value)
                    {
                      setState(() => activeStep = index)
                      // if (index == 0) {
                      //   userController.commande.value.contact = true;
                      // } else if (index == 1) {
                      //   userController.commande.value.decoupes = true;
                      // } else if (index == 2) {
                      //   userController.commande.value.assemblage = true;
                      // } else if (index == 3) {
                      //   userController.commande.value.payment = true;
                      // } else if (index == 4) {
                      //   userController.commande.value.livraison = true;
                      // } else if (index == 5) {
                      //   userController.commande.value.terminer = true;
                      // }
                    },
                }),
      ],
    );
  }
}
