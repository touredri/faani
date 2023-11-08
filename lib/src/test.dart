import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/src/widgets.dart';
import 'package:flutter/material.dart';

import '../modele/modele.dart';

class HomePAgeView extends StatefulWidget {
  const HomePAgeView({super.key});

  @override
  State<HomePAgeView> createState() => _HomePAgeViewState();
}

class _HomePAgeViewState extends State<HomePAgeView> {
  List<Modele> modeles = [];

  @override
  void initState() {
    super.initState();
    fetchModeles();
  }

  Future<void> fetchModeles() async {
    final modelesData = await getAllModeles();
    setState(() {
      modeles = modelesData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Expanded(
      child: PageView.builder(
      controller: controller,
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        if (modeles.isNotEmpty && index < modeles.length) {
          final modele = modeles[index];
          return homeItem(modele);
        } else {
          return const SizedBox.shrink();
        }
      },
    ));
  }
}
