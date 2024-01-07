import 'package:faani/pages/commande/widget/search_bar.dart';
import 'package:flutter/material.dart';

class ListTailleur extends StatefulWidget {
  const ListTailleur({super.key});

  @override
  State<ListTailleur> createState() => _ListTailleurState();
}

class _ListTailleurState extends State<ListTailleur> {
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
