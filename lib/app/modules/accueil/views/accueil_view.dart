import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import '../../globale_widgets/list_categorie.dart';
import '../controllers/accueil_controller.dart';
import '../widgets/accueil_page_view.dart';

class AccueilView extends GetView<AccueilController> {
  const AccueilView({Key? key}) : super(key: key);
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
          Container(
            width: double.infinity,
            height: double.infinity,
            child: AccueilPAgeView(),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.25,
            child: Row(
              children: [
                Obx(() => Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.isHommeSelected.value = true;
                          },
                          child: Text('Homme',
                              style: TextStyle(
                                  color: controller.isHommeSelected.value
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  fontWeight: controller.isHommeSelected.value
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: controller.isHommeSelected.value
                                      ? 20
                                      : 15)),
                        ),
                        const Text(
                          '|',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.isHommeSelected.value = false;
                          },
                          child: Text('Femme',
                              style: TextStyle(
                                  color: !controller.isHommeSelected.value
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  fontWeight: !controller.isHommeSelected.value
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: !controller.isHommeSelected.value
                                      ? 20
                                      : 15)),
                        ),
                      ],
                    )),
                10.ws,
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 30,
                    )),
              ],
            ),
          ),
          // categories list
          Positioned(
            top: 50,
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: CategorieFiltre(
                  onCategorieSelected: controller.onCategorieSelected,
                )),
          ),
        ],
      ),
    );
  }
}
