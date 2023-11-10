import 'dart:math';

import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/src/widgets.dart';
import 'package:flutter/material.dart';

import '../modele/modele.dart';

class HomePAgeView extends StatefulWidget {
  final List<Modele> modeles;
  const HomePAgeView({super.key, required this.modeles});
  @override
  State<HomePAgeView> createState() => _HomePAgeViewState();
}

class _HomePAgeViewState extends State<HomePAgeView> {
  // List<Modele> modeles = [];

  @override
  void initState() {
    super.initState();
    // getAllModeles().listen((event) {
    //   setState(() {
    //     modeles = event;
    //   });
    // });
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
          return homeItem(modele);
        } else {
          return const SizedBox.shrink();
        }
      },
    ));
  }
}
