import 'dart:math';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/globale_widgets/list_categorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../../style/my_theme.dart';

class MesModelesView extends GetView {
  const MesModelesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Modele>>(
          stream: null,
          builder: (context, snapshot) {
            return CustomScrollView(
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
                  expandedHeight: 140.0,
                  floating: true,
                  snap: true,
                  // pinned: true,
                  title: const Text(
                    "Mes Modèles",
                    style: TextStyle(color: Colors.white),
                  ),
                  bottom: PreferredSize(
                      preferredSize: const Size(double.infinity, 40),
                      child: Container(
                        color: primaryColor,
                        width: MediaQuery.of(context).size.width,
                        height: 30,
                        child: CategorieFiltre(),
                      )),
                  flexibleSpace: const FlexibleSpaceBar(
                    background: Padding(
                      padding: EdgeInsets.only(top: 75.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.accessibility_rounded,
                                color: Colors.white,
                              ),
                              Text('20', style: TextStyle(color: Colors.white))
                            ],
                          ),
                          Column(
                            children: [
                              Icon(
                                Icons.sms,
                                color: Colors.white,
                              ),
                              Text('10 ', style: TextStyle(color: Colors.white))
                            ],
                          ),
                          Column(
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
                  child: MasonryGridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return _buildCard('assets/images/no_favori.png');
                    },
                  ),
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildCard(String imageUrl) {
  final imageHeight = (Random().nextInt(4) + 1) * 150.0;
  return Card(
    child: Image.asset(
      imageUrl,
      height: imageHeight,
      fit: BoxFit.cover,
    ),
  );
}
