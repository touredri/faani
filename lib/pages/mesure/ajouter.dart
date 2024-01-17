import 'package:faani/my_theme.dart';
import 'package:faani/pages/mesure/widget/mesure_page_view.dart';
import 'package:flutter/material.dart';

class AjoutMesure extends StatelessWidget {
  const AjoutMesure({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 236, 236),
      ),
      body: Container(
        color: const Color.fromARGB(255, 240, 236, 236),
        height: double.infinity,
        child: Column(
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Image.asset('../../../assets/images/measurement.png')),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MesurePaveView()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 28.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              '../../../assets/images/manual_measurements.png',
                              width: 35,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'Ajout manuel',
                              style:
                                  TextStyle(fontSize: 18, color: primaryColor),
                            )
                          ],
                        ),
                      )),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Fonctionnalité en cours'),
                              content: const Text('Arrive bientôt!  😊'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 28.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_sharp, color: primaryColor),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Par caméra',
                              style:
                                  TextStyle(fontSize: 18, color: primaryColor),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
