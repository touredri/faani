import 'dart:math';

import 'package:faani/app/modules/globale_widgets/list_categorie.dart';
import 'package:faani/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';

class MesModelesView extends GetView {
  const MesModelesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
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
                preferredSize: Size(double.infinity, 40),
                child: Container(
                  color: primaryColor,
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                  child: CategorieFiltre(),
                )),
            // shape: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
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
          SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 13,
                // childAspectRatio: MediaQuery.of(context).size.width /
                //     (MediaQuery.of(context).size.height / 1.2),
              ),
              itemCount: 50,
              itemBuilder: (context, index) {
                return _buildCard('assets/images/no_favori.png');
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildCard(String imageUrl) {
  final imageHeight = (Random().nextInt(4) + 1) * 200.0;
  return Card(
    child: Image.asset(
      imageUrl,
      height: imageHeight,
      fit: BoxFit.cover,
    ),
  );
}
