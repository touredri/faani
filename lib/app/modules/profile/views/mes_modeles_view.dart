import 'dart:math';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/ajout_modele/controllers/ajout_modele_controller.dart';
import 'package:faani/app/modules/ajout_modele/views/ajout_modele.dart';
import 'package:faani/app/modules/ajout_modele/widgets/modele_form.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/globale_widgets/list_categorie.dart';
import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../../style/my_theme.dart';

class MesModelesView extends GetView {
  const MesModelesView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            backgroundColor: primaryColor,
            expandedHeight: 108.0,
            floating: true,
            snap: true,
            pinned: true,
            bottom: PreferredSize(
                preferredSize: const Size(double.infinity, 35),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  color: primaryColor,
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  child: CategorieFiltre<ProfileController>(
                    controller: controller,
                  ),
                )),
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.accessibility_rounded,
                          color: Colors.white,
                        ),
                        Text(controller.myTotalModeleNumber.toString(),
                            style: const TextStyle(color: Colors.white))
                      ],
                    ),
                    const Column(
                      children: [
                        Icon(
                          Icons.sms,
                          color: Colors.white,
                        ),
                        Text('10 ', style: TextStyle(color: Colors.white))
                      ],
                    ),
                    const Column(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.white,
                        ),
                        Text('25', style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: GetBuilder<ProfileController>(
              init: ProfileController(),
              initState: (_) {},
              id: 'mesModeles',
              builder: (_) {
                return MasonryGridView.count(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.only(bottom: 10),
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: controller.mesModelesList.value.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                            () => DetailModeleView(
                                controller.mesModelesList.value[index]!),
                            arguments: controller.mesModelesList.value[index]);
                      },
                      child: _buildCard(
                          controller.mesModelesList.value[index]!.fichier[0]!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Get.put(AjoutModeleController());
          Get.to(() => const AjoutModeleForm());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildCard(String imageUrl) {
  final imageHeight = (Random().nextInt(4) + 1) * 100.0;
  return Card(
    clipBehavior: Clip.antiAliasWithSaveLayer,
    child: Image.network(
      imageUrl,
      height: imageHeight,
      fit: BoxFit.cover,
    ),
  );
}
