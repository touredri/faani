import 'package:faani/app/modules/mesures/views/widgets/page_view_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import '../../../../style/my_theme.dart';
import '../../controllers/mesures_controller.dart';
import 'save_mesure.dart';

class MesurePaveView extends StatelessWidget {
  const MesurePaveView({super.key});


  @override
  Widget build(BuildContext context) {
    final MesuresController mesureController = Get.put(MesuresController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBack,
        surfaceTintColor: scaffoldBack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            mesureController.pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        actions: [
          IconButton(
              padding: const EdgeInsets.only(right: 20),
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close, color: Colors.black))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: PageView(
                onPageChanged: (index) {
                  if (index == 7) {
                    mesureController.isLastPage.value = true;
                  } else {
                    mesureController.isLastPage.value = false;
                  }
                },
                scrollBehavior: const ScrollBehavior(),
                controller: mesureController.pageController,
                children: [
                  PageViewContent(
                    text: 'Epaule',
                    count: '1/8',
                    imagePath: 'assets/images/epaules.jpg',
                    controller: mesureController.epauleController,
                  ),
                  PageViewContent(
                    text: 'Bras',
                    count: '2/8',
                    imagePath: 'assets/images/bras.jpg',
                    controller: mesureController.brasController,
                  ),
                  PageViewContent(
                    text: 'Hanche',
                    count: '3/8',
                    imagePath: 'assets/images/hanche.jpg',
                    controller: mesureController.hancheController,
                  ),
                  PageViewContent(
                    text: 'Poitrine',
                    count: '4/8',
                    imagePath: 'assets/images/poitrine.jpg',
                    controller: mesureController.poitrineController,
                  ),
                  PageViewContent(
                    text: 'Taille',
                    count: '5/8',
                    imagePath: 'assets/images/taille.jpg',
                    controller: mesureController.tailleController,
                  ),
                  PageViewContent(
                    text: 'Ventre',
                    count: '6/8',
                    imagePath: 'assets/images/ventre.jpg',
                    controller: mesureController.ventreController,
                  ),
                  PageViewContent(
                    text: 'Longueur',
                    count: '7/8',
                    imagePath: 'assets/images/longueur.jpg',
                    controller: mesureController.longeurController,
                  ),
                  PageViewContent(
                    text: 'Poignet',
                    count: '8/8',
                    imagePath: 'assets/images/poignet.jpg',
                    controller: mesureController.poignetController,
                  ),
                ],
              ),
            ),
            2.hs,
            Obx(() => Container(
                  alignment: Alignment.bottomCenter,
                  child: mesureController.isLastPage.value &&
                          mesureController.pageController.hasClients
                      ? TextButton(
                          onPressed: () {
                            TextEditingController nameController =
                                TextEditingController();
                            dialogBox(context, nameController, mesureController);
                          },
                          child: textContainer('Terminer'))
                      : TextButton(
                          onPressed: () {
                            mesureController.pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: textContainer('Continuer')),
                )),
          ],
        ),
      ),
    );
  }
}

Container textContainer(String text) {
  return Container(
    height: 40,
    width: 200,
    padding: const EdgeInsets.symmetric(
      vertical: 4,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: inputBorderColor, width: 1),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        color: primaryColor,
      ),
    ),
  );
}
