import 'package:flutter/material.dart';

import 'package:get/get.dart';

class AjoutMesureView extends GetView {
  const AjoutMesureView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AjoutMesureView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AjoutMesureView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
