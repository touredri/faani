import 'package:flutter/material.dart';

import 'package:get/get.dart';

class MesModelesView extends GetView {
  const MesModelesView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MesModelesView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MesModelesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
