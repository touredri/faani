import 'package:flutter/material.dart';

class FavoriesPage extends StatefulWidget {
  const FavoriesPage({super.key});

  @override
  State<FavoriesPage> createState() => _FavoriesPageState();
}

class _FavoriesPageState extends State<FavoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(child: Text('Favories')),
    );
  }
}