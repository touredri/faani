import 'package:faani/pages/commande/widget/search_bar.dart';
import 'package:flutter/material.dart';

class CommandeLivrer extends StatefulWidget {
  const CommandeLivrer({super.key});

  @override
  State<CommandeLivrer> createState() => _CommandeLivrerState();
}

class _CommandeLivrerState extends State<CommandeLivrer> {
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
