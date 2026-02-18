import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/modules/accueil/widgets/accueil_model_view.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/style/editorial_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// TikTok‑like vertical scroll view filtered to a single category.
/// Opened when a user taps a grid item — shows items of the same category.
class CategoryScrollView extends StatefulWidget {
  final Modele initialModele;
  final String idCategorie;

  const CategoryScrollView({
    super.key,
    required this.initialModele,
    required this.idCategorie,
  });

  @override
  State<CategoryScrollView> createState() => _CategoryScrollViewState();
}

class _CategoryScrollViewState extends State<CategoryScrollView> {
  PageController? _pageController;
  List<Modele> _modeles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadModeles();
  }

  Future<void> _loadModeles() async {
    final stream =
        ModeleService().getAllModelesByCategorie(widget.idCategorie);
    stream.listen((list) {
      if (mounted) {
        // Find the index of the tapped model so we start there
        int idx = list.indexWhere((m) => m.id == widget.initialModele.id);
        if (idx < 0) idx = 0;
        setState(() {
          _modeles = list;
          _pageController = PageController(initialPage: idx);
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EditorialTheme.charcoal,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: EditorialTheme.charcoal,
      ),
      body: _loading
          ? Center(child: circularProgress())
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageController!,
                  scrollDirection: Axis.vertical,
                  itemCount: _modeles.length,
                  itemBuilder: (context, index) {
                    return HomeItem(_modeles[index]);
                  },
                ),
                // Back button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: EditorialTheme.offWhite,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
