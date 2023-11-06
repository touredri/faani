import 'package:faani/src/widgets.dart';
import 'package:flutter/material.dart';

import 'src/home_item_list.dart';
import 'src/test.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _nameState();
}

class _nameState extends State<HomePage> {
  bool isHommeSelected = true;
  bool isFemmeSelected = false;
  String currentFilterSelected = 'Bazin';

  void changeFilter(String newFilter) {
    setState(() {
      currentFilterSelected = newFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Faani',
              style: TextStyle(
                color: Color(0xFFF3755F),
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isHommeSelected = true;
                      isFemmeSelected = false;
                    });
                  },
                  child: Text('Homme',
                      style: TextStyle(
                        color: isHommeSelected
                            ? Colors.black
                            : Colors.black.withOpacity(0.6),
                      )),
                ),
                const Text(
                  '|',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isHommeSelected = false;
                      isFemmeSelected = true;
                    });
                  },
                  child: Text('Femme',
                      style: TextStyle(
                        color: isFemmeSelected
                            ? Colors.black
                            : Colors.black.withOpacity(0.6),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(children: [
            Container(
              height: 30,
              width: 120,
              margin: const EdgeInsets.only(left: 5),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
                icon: const Icon(Icons.explore_rounded, size: 20),
                label: const Text('Explore'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black, // Text and icon color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFA4CEFB)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 1),
            Container(
              width: 230,
              height: 40,
              padding: const EdgeInsets.all(0),
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  myFilterContainer('Bazin', () => changeFilter('Bazin'),
                      currentFilterSelected),
                  myFilterContainer('Tissu', () => changeFilter('Tissu'),
                      currentFilterSelected),
                  myFilterContainer(
                      'Wax', () => changeFilter('Wax'), currentFilterSelected),
                  myFilterContainer('Satin', () => changeFilter('Satin'),
                      currentFilterSelected),
                  myFilterContainer('Soie', () => changeFilter('Soie'),
                      currentFilterSelected),
                ],
              ),
            )
          ]),
          // HomeItemList(),
          // Expanded(child: TikTokScrollEffect())
          const HomePAgeView()
        ],
      ),
    );
  }
}
