import 'package:faani/pages/commande/widget/search_bar.dart';
import 'package:flutter/material.dart';

class SavedCommande extends StatefulWidget {
  const SavedCommande({super.key});

  @override
  State<SavedCommande> createState() => _SavedCommandeState();
}

class _SavedCommandeState extends State<SavedCommande> {
  final TextEditingController _filter = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter.addListener(() => setState(() {}));
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: CommandeSearchBar(controller: _filter),
        ),
      ]),
    );
  }
}