import 'package:faani/my_theme.dart';
import 'package:faani/app/modules/mesures/views/widgets/mesure_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';

class AjoutMesure extends GetView {
  const AjoutMesure({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBack,
      ),
      body: SizedBox(
        height: double.infinity,
        child: Column(
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Image.asset('/assets/images/measurement.png')),
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MesurePaveView()));
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
                              'assets/images/manual_measurements.png',
                              width: 35,
                            ),
                            3.ws,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_sharp,
                                color: primaryColor),
                            3.ws,
                            const Text(
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
