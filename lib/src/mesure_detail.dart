import 'package:faani/modele/classes.dart';
import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';

class DetailMesure extends StatelessWidget {
  final Mesure? mesure;
  const DetailMesure({super.key, this.mesure});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail de la mesure'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 17, right: 17),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 3, right: 3),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mesure 1', style: TextStyle(fontSize: 20)),
                      Text('10-10-2021'),
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.delete,
                        size: 30,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Divider(
              color: primaryColor,
            ),
            Expanded(
              child: Container(
                height: 400,
                child: Column(children: [
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        ListTile(
                          title:
                              Text('Epaulel', style: TextStyle(fontSize: 18)),
                          trailing: Container(
                            width: 110,
                            child: Row(
                              children: [
                                Text('45 cm', style: TextStyle(fontSize: 18)),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        ListTile(
                          title:
                              Text('Epaulel', style: TextStyle(fontSize: 18)),
                          trailing: Container(
                            width: 110,
                            child: Row(
                              children: [
                                Text('45 cm', style: TextStyle(fontSize: 18)),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        ListTile(
                          title:
                              Text('Epaulel', style: TextStyle(fontSize: 18)),
                          trailing: Container(
                            width: 110,
                            child: Row(
                              children: [
                                Text('45 cm', style: TextStyle(fontSize: 18)),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        ListTile(
                          title:
                              Text('Epaulel', style: TextStyle(fontSize: 18)),
                          trailing: Container(
                            width: 110,
                            child: Row(
                              children: [
                                Text('45 cm', style: TextStyle(fontSize: 18)),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        ListTile(
                          title:
                              Text('Epaulel', style: TextStyle(fontSize: 18)),
                          trailing: Container(
                            width: 110,
                            child: Row(
                              children: [
                                Text('45 cm', style: TextStyle(fontSize: 18)),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        ListTile(
                          title:
                              Text('Epaulel', style: TextStyle(fontSize: 18)),
                          trailing: Container(
                            width: 110,
                            child: Row(
                              children: [
                                Text('45 cm', style: TextStyle(fontSize: 18)),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
