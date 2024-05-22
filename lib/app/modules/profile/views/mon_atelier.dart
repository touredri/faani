import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MonAtelier extends GetView<ProfileController> {
  const MonAtelier({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: primaryBackAppBar('Mon Atelier'),
      body: ConstrainedBox(constraints: const BoxConstraints.expand(),
      child: Stack(
        children: [
          

          Positioned(
            bottom: 0,
            top: 60,
            child: Container())
        ],
      ),
      ),
    );
  }
}