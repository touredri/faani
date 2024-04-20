import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import '../../globale_widgets/list_categorie.dart';
import '../controllers/accueil_controller.dart';
import '../widgets/accueil_page_view.dart';

class AccueilView extends GetView<AccueilController> {
  const AccueilView({super.key});

  @override
  Widget build(BuildContext context) {
    final AccueilController controller = Get.put(AccueilController());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      ),
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      body: Stack(
        children: [
          // list view builder for images & videos in infinite scroll
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.92,
            child: const AccueilPAgeView(),
          ),
          // filter and search icon
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 51, 51, 51).withOpacity(0.4),
            ),
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    controller.isHommeSelected.value
                        ? TextButton(
                            onPressed: () {
                              controller.isHommeSelected.value =
                                  !controller.isHommeSelected.value;
                                  controller.modeles.clear();
                                  controller.loadMore('Homme', '');
                            },
                            child: const Text('Homme',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          )
                        : TextButton(
                            onPressed: () {
                              controller.isHommeSelected.value =
                                  !controller.isHommeSelected.value;
                                  controller.modeles.clear();
                                  controller.loadMore('Femme', '');
                            },
                            child: const Text('Femme',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ),
                    Expanded(
                      child: CategorieFiltre<AccueilController>(controller: controller,),
                    ),
                    IconButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0)),
                        ),
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 25,
                        )),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
