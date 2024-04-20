import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../style/my_theme.dart';

class CategorieFiltre<T extends GetxController> extends StatefulWidget {
  final T controller;
  const CategorieFiltre({super.key, required this.controller});

  @override
  State<CategorieFiltre> createState() => _CategorieFiltreState<T>();
}

class _CategorieFiltreState<T extends GetxController>
    extends State<CategorieFiltre<T>> {
  final ScrollController _scrollController = ScrollController();
  final double itemHeight = 50;
  RxList<Categorie> listCategorie = <Categorie>[].obs;

  // fetch categories from the database
  void getCategories() {
    CategorieService().getCategorie().listen((event) {
      if (event.isNotEmpty) {
        listCategorie.value = event;
      }
    });
  }

  void _scrollToCenter(int selectedIndex, BuildContext context) {
    const itemWidth = 40;
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
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
              ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listCategorie.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  final categorie = listCategorie[index];
                  return TextButton(
                    onPressed: () {
                      for (int i = 0; i < listCategorie.length; i++) {
                        listCategorie[i].isSelected =
                            (i == int.parse(categorie.id) - 1);
                      }
                      setState(() {
                        _scrollToCenter(index, context);
                      });
                      (widget.controller as dynamic)
                          .onCategorieSelected(categorie);
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
                        fontWeight:
                            categorie.isSelected ? FontWeight.bold : FontWeight.normal,
                        height: categorie.isSelected ? 1 : 0,
                      ),
                    ),
                  );
                },
              )
            );
  }
}
