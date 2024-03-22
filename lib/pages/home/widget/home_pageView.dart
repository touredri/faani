import 'package:faani/pages/home/widget/home_view.dart';
import 'package:faani/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../../app/data/models/modele_model.dart';

class HomePAgeView extends StatefulWidget {
  final List<Modele> modeles;
  const HomePAgeView({super.key, required this.modeles});
  @override
  State<HomePAgeView> createState() => _HomePAgeViewState();
}

class _HomePAgeViewState extends State<HomePAgeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Expanded(
        child: PageView.builder(
      controller: controller,
      scrollDirection: Axis.vertical,
      itemCount: widget.modeles.length,
      itemBuilder: (context, index) {
        if (widget.modeles.isNotEmpty && index < widget.modeles.length) {
          final modele = widget.modeles[index];
          return homeItem(modele, context);
        } else {
          return const SizedBox.shrink();
        }
      },
    ));
  }
}
