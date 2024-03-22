import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DevenirTailleurView extends GetView {
  const DevenirTailleurView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DevenirTailleurView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DevenirTailleurView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
