import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DetailCommandeView extends GetView {
  const DetailCommandeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailCommandeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailCommandeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
