import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/modele/tendance.dart';
import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';

import '../firebase_get_all_data.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late final PageController _controller;
  late final Timer _timer;
  int length = 0;
  int indice = 0;

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      viewportFraction: 0.85,
      initialPage: indice,
    );
  }

  // void setList(List<Tendance> tendances) {
  //   setState(() {
  //     atendances = tendances;
  //   });
  // }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  List<Tendance> atendances = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: primaryColor,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(children: [
            Stack(
              children: [
                StreamBuilder<List<Tendance>>(
                    stream: getAllTendance(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final tendances = snapshot.data!;
                        // setList(tendances);
                        length = tendances.length;
                        Timer.periodic(const Duration(seconds: 4), (timer) {
                          if (indice == length) {
                            indice = 0;
                          }
                          _controller.animateToPage(
                            indice,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeIn,
                          );
                          indice++;
                        });

                        return Column(
                          children: [
                            Container(
                              color: Colors.grey[200],
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              height: 500,
                              width: MediaQuery.of(context).size.width,
                              child: PageView.builder(
                                controller: _controller,
                                itemCount: length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      print(tendances[index].id);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        tendances[index].image,
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10),
                              child: const Text('Decouvrez les tendances',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              height: 700,
                              child: GridView.builder(
                                itemCount: tendances.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio:
                                      MediaQuery.of(context).size.width /
                                          (MediaQuery.of(context).size.height /
                                              1.2),
                                ),
                                itemBuilder: (context, index) {
                                  final modele = tendances[index];
                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigator.of(context).push(MaterialPageRoute(
                                        //     builder: (BuildContext context) =>
                                        //         DetailModele(modele: modele)));
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: modele.image,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(
                                          child: Image.asset(
                                              'assets/images/loading.gif'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
                Container(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: primaryColor,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }
}
