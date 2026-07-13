import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'accueil_model_view.dart';
import '../controllers/accueil_controller.dart';

/// Opens when a user taps a masonry grid item. Scrolls through
/// other models in the same category.
class CategoryFeedView extends StatefulWidget {
  final List<Modele> modeles;
  final int initialIndex;
  final String? categoryName;
  final AccueilController controller;

  const CategoryFeedView({
    super.key,
    required this.modeles,
    required this.initialIndex,
    required this.controller,
    this.categoryName,
  });

  @override
  State<CategoryFeedView> createState() => _CategoryFeedViewState();
}

class _CategoryFeedViewState extends State<CategoryFeedView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.categoryName != null
            ? Text(
                widget.categoryName!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.modeles.length,
        itemBuilder: (context, index) {
          return HomeItem(
            widget.modeles[index],
            controller: widget.controller,
          );
        },
      ),
    );
  }
}
