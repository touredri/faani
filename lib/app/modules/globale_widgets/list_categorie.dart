import 'package:faani/app/data/services/categorie_service.dart';
import 'package:faani/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/categorie_model.dart';
import '../accueil/controllers/accueil_controller.dart';

class CategorieFiltre extends StatefulWidget {
  CategorieFiltre({super.key});

  @override
  State<CategorieFiltre> createState() => _CategorieFiltreState();
}

class _CategorieFiltreState extends State<CategorieFiltre> {
  final ScrollController _scrollController = ScrollController();

  final double itemHeight = 50;

  void _scrollToCenter(int selectedIndex, BuildContext context) {
    // final itemWidth =
    //     (context.findRenderObject() as RenderBox?)?.size.width ?? 0;
    final itemWidth = 40;
    final scrollOffset = selectedIndex * itemWidth -
        (MediaQuery.of(context).size.width / 2 - itemWidth / 2);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        scrollOffset.clamp(0.0, double.infinity),
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AccueilController controller = Get.put(AccueilController());
    return Obx(() => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.listCategorie.length,
          controller: _scrollController,
          itemBuilder: (context, index) {
            final categorie = controller.listCategorie[index];
            return TextButton(
              onPressed: () {
                for (int i = 0; i < controller.listCategorie.length; i++) {
                  controller.listCategorie[i].isSelected =
                      (i == int.parse(categorie.id) - 1);
                }
                setState(() {
                  _scrollToCenter(index, context);
                });
                // controller.isFilterOpen.value = false;
                // controller.onCategorieSelected(categorie);
              },
              child: Text(
                categorie.libelle,
                style: TextStyle(
                  fontSize: categorie.isSelected ? 16 : 14,
                  color: categorie.isSelected
                      ? Colors.white
                      : const Color.fromARGB(255, 231, 231, 231),
                  decorationColor: primaryColor,
                  decoration: categorie.isSelected
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontWeight: categorie.isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  height: categorie.isSelected ? 1 : 0,
                ),
              ),
            );
          },
        ));
  }
}
