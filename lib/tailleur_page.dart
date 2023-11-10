import 'package:flutter/material.dart';

class TailleurPage extends StatefulWidget {
  const TailleurPage({super.key});

  @override
  State<TailleurPage> createState() => _TailleurPageState();
}

class _TailleurPageState extends State<TailleurPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(child: Text('Tailleur')),
    );
  }
}