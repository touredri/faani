import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/modules/mesures/views/widgets/mesure_page_view.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class AjoutMesure extends GetView {
  const AjoutMesure({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SizedBox(
        height: double.infinity,
        child: Column(
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Image.asset(
                  'assets/images/measurement.png',
                  width: double.infinity,
                )),
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                children: [
                  TextButton(
                      onPressed: () {
                        pushWithoutNavBar(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MesurePaveView()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 28.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.grey300, width: 1),
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
                                  TextStyle(fontSize: 15, color: Colors.black),
                            )
                          ],
                        ),
                      )),
                  2.hs,
                  TextButton(
                      onPressed: () {
                        final navigatorContext =
                            Navigator.of(context, rootNavigator: true).context;
                        showDialog(
                          context: navigatorContext,
                          useRootNavigator: true,
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
                          border:
                              Border.all(color: AppColors.grey300, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_sharp,
                                color: AppColors.primary),
                            3.ws,
                            const Text(
                              'Par caméra',
                              style: TextStyle(
                                  fontSize: 15, color: AppColors.primary),
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
