import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';

class DetailCommandeView extends GetView {
  final Modele modele;
  const DetailCommandeView(this.modele, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: DisplayImage(modele: modele)),
            1.hs,
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  child: Image.network(''),
                ),
                title: const Text('gggggg'),
                subtitle: const Text('kkkkkkkkk'),
                trailing: const Text('m'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
