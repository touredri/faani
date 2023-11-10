import 'package:flutter/material.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(child: Text('Commande')),
    );
  }
}