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
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.92,
            child: AccueilPAgeView(),
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
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              controller.isFilterOpen.value =
                                  !controller.isFilterOpen.value;
                            },
                            icon: const Icon(
                              Icons.filter_list_alt,
                              color: Colors.white,
                              size: 30,
                            )),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: controller.isFilterOpen.value
                              ? MediaQuery.of(context).size.width * 0.8
                              : 0,
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: controller.isFilterOpen.value
                                  ? 1
                                  : 0,
                              child: CategorieFiltre(
                                  // onCategorieSelected:
                                  //     controller.onCategorieSelected,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: !controller.isFilterOpen.value,
                      child: Row(
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
                              color: Colors.white,
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
                                    fontWeight:
                                        !controller.isHommeSelected.value
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: !controller.isHommeSelected.value
                                        ? 20
                                        : 15)),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !controller.isFilterOpen.value,
                      child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 30,
                          )),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
