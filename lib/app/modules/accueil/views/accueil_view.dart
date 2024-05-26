import 'package:faani/app/modules/search_page/views/search_page_view.dart';
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
    Get.put(AccueilController());
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
                    TextButton(
                      onPressed: () {
                        controller.genreChange();
                      },
                      child: Text(
                          controller.isHommeSelected.value ? 'Homme' : 'Femme',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 26,
                        child: CategorieFiltre<AccueilController>(
                          controller: controller,
                        ),
                      ),
                    ),
                    IconButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0)),
                        ),
                        onPressed: () {
                          Get.to(() => const SearchPageView(),
                              transition: Transition.downToUp);
                        },
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
