import 'package:faani/app/data/services/categorie_service.dart';
import 'package:flutter/material.dart';
import '../../data/models/categorie_model.dart';

class CategorieFiltre extends StatefulWidget {
  final Function(Categorie) onCategorieSelected;

  const CategorieFiltre({
    Key? key,
    required this.onCategorieSelected,
  }) : super(key: key);

  @override
  State<CategorieFiltre> createState() => _CategorieFiltreState();
}

class _CategorieFiltreState extends State<CategorieFiltre> {
  final ScrollController _scrollController = ScrollController();
  final double itemHeight = 50;

  @override
  void initState() {
    super.initState();
    // _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCenter(int selectedIndex) {
    final itemWidth =
        (context.findRenderObject() as RenderBox?)?.size.width ?? 0;
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
    final CategorieService categorieService = CategorieService();
    return StreamBuilder<List<Categorie>>(
      stream: categorieService.getCategorie(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final categories = snapshot.data!;
          categories[2].isSelected = true;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categorie = categories[index];
              return GestureDetector(
                onTap: () {
                  // Mettre à jour la catégorie sélectionnée
                  setState(() {
                    for (int i = 0; i < categories.length; i++) {
                      categories[i].isSelected = (i == index);
                    }
                  });
                  _scrollToCenter(index);

                  widget.onCategorieSelected(categorie);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  height: itemHeight,
                  child: Text(
                    categorie.libelle,
                    style: TextStyle(
                      fontSize: categorie.isSelected ? 18 : 14,
                      color: categorie.isSelected ? Colors.white : Colors.black,
                      fontWeight: categorie.isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
