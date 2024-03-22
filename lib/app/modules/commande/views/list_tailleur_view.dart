import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ListTailleurView extends GetView {
  const ListTailleurView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListTailleurView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ListTailleurView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
