import 'dart:math';

import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../modele/mesure.dart';
import '../my_theme.dart';
// import '../my_theme.dart';

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
                child: Image.asset('assets/images/measurement.png')),
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
                              'assets/images/manual_measurements.png',
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

class MesurePaveView extends StatefulWidget {
  const MesurePaveView({super.key});

  @override
  State<MesurePaveView> createState() => _MesurePaveViewState();
}

class _MesurePaveViewState extends State<MesurePaveView> {
  final PageController _pageController = PageController(initialPage: 0);
  final TextEditingController _epauleController = TextEditingController();
  final TextEditingController _ventreController = TextEditingController();
  final TextEditingController _poitrineController = TextEditingController();
  final TextEditingController _longeurController = TextEditingController();
  final TextEditingController _hancheController = TextEditingController();
  final TextEditingController _brasController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _poignetController = TextEditingController();

  void onChnageEpaule(String value) {
    _epauleController.text = value;
    setState(() {});
  }

  void onChangeVentre(String value) {
    _ventreController.text = value;
    setState(() {});
  }

  void onChangePoitrine(String value) {
    _poitrineController.text = value;
    setState(() {});
  }

  void onChangeLongueur(String value) {
    _longeurController.text = value;
    setState(() {});
  }

  void onChangeHanche(String value) {
    _hancheController.text = value;
    setState(() {});
    print('hanche: $value');
  }

  void onChangeBras(String value) {
    _brasController.text = value;
    setState(() {});
    print('bras: $value');
  }

  void onChangeTaille(String value) {
    _tailleController.text = value;
    setState(() {});
  }

  void onChangePoignet(String value) {
    _poignetController.text = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 236, 236),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        title: Row(
          children: [
            const Text(''),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close, color: Colors.black))
          ],
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 240, 236, 236),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: PageView(
                  onPageChanged: (index) {
                    if (index == 7) {
                      Provider.of<ApplicationState>(context, listen: false)
                          .lastPage = true;
                    } else {
                      Provider.of<ApplicationState>(context, listen: false)
                          .lastPage = false;
                    }
                  },
                  scrollBehavior: const ScrollBehavior(),
                  controller: _pageController,
                  children: [
                    PageViewContent(
                        text: 'Epaule',
                        count: '1/8',
                        imagePath: 'assets/images/epaules.jpg',
                        controller: _epauleController,
                        onChanged: onChnageEpaule),
                    PageViewContent(
                        text: 'Bras',
                        count: '2/8',
                        imagePath: 'assets/images/bras.jpg',
                        controller: _brasController,
                        onChanged: onChangeBras),
                    PageViewContent(
                        text: 'Hanche',
                        count: '3/8',
                        imagePath: 'assets/images/hanche.jpg',
                        controller: _hancheController,
                        onChanged: onChangeHanche),
                    PageViewContent(
                        text: 'Poitrine',
                        count: '4/8',
                        imagePath: 'assets/images/poitrine.jpg',
                        controller: _poitrineController,
                        onChanged: onChangePoitrine),
                    PageViewContent(
                        text: 'Taille',
                        count: '5/8',
                        imagePath: 'assets/images/taille.jpg',
                        controller: _tailleController,
                        onChanged: onChangeTaille),
                    PageViewContent(
                        text: 'Ventre',
                        count: '6/8',
                        imagePath: 'assets/images/ventre.jpg',
                        controller: _ventreController,
                        onChanged: onChangeVentre),
                    PageViewContent(
                        text: 'Longueur',
                        count: '7/8',
                        imagePath: 'assets/images/longueur.jpg',
                        controller: _longeurController,
                        onChanged: onChangeLongueur),
                    PageViewContent(
                        text: 'Poignet',
                        count: '8/8',
                        imagePath: 'assets/images/poignet.jpg',
                        controller: _poignetController,
                        onChanged: onChangePoignet),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: context.watch<ApplicationState>().isLastPage
                    ? TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController _nameController =
                                  TextEditingController();
                              return AlertDialog(
                                title: Text('Entrer un nom pour la mesure'),
                                content: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(hintText: "Name"),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Soumettre'),
                                    onPressed: () {
                                      String name = _nameController.text;
                                      Measure newMeasure = Measure(
                                        bras: int.tryParse(
                                                _brasController.text) ??
                                            0,
                                        epaule: int.tryParse(
                                                _epauleController.text) ??
                                            0,
                                        hanche: int.tryParse(
                                                _hancheController.text) ??
                                            0,
                                        idUser: '1',
                                        longueur: int.tryParse(
                                                _longeurController.text) ??
                                            0,
                                        poitrine: int.tryParse(
                                                _poitrineController.text) ??
                                            0,
                                        nom: name,
                                        taille: int.tryParse(
                                                _tailleController.text) ??
                                            0,
                                        ventre: int.tryParse(
                                                _ventreController.text) ??
                                            0,
                                        poignet: int.tryParse(
                                                _poignetController.text) ??
                                            0,
                                        id: '',
                                        date: DateTime.now(),
                                      );
                                      newMeasure.create();
                                      Provider.of<ApplicationState>(context,
                                              listen: false)
                                          .lastPage = false;
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 200,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: inputBorderColor, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Text(
                            'Enregistrer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: primaryColor,
                            ),
                          ),
                        ))
                    : TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 200,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: inputBorderColor, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Text(
                            'Continuer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: primaryColor,
                            ),
                          ),
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageViewContent extends StatelessWidget {
  final String text;
  final String imagePath;
  final String count;
  final TextEditingController controller;
  final Function onChanged;
  PageViewContent({
    required this.text,
    required this.imagePath,
    required this.controller,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // controller.text = context.watch<ApplicationState>().currentValue.toString();
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Text(count, style: const TextStyle(fontSize: 20, color: primaryColor)),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              )),
        ),
        const SizedBox(
          height: 40,
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              Container(
                width: 207,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        int currentValue = int.tryParse(controller.text) ?? 0;
                        if (currentValue > 0) {
                          controller.text = (currentValue - 1).toString();
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) {
                          // Provider.of<ApplicationState>(context, listen: false)
                          //     .currentValue = int.tryParse(value) ?? 0;
                          // onChanged(value);
                        },
                        // maxLength: 3,
                        style: const TextStyle(
                          // height: 3,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          // counter: const Text(''),
                          labelText: 'mésure',
                          labelStyle: const TextStyle(color: Colors.blue),
                          filled: true,
                          fillColor: Colors.grey[200],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: inputBorderColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                      ),
                      // ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        int currentValue = int.tryParse(controller.text) ?? 0;
                        controller.text = (currentValue + 1).toString();
                      },
                    ),
                  ],
                ),
              ),
              const Text('Cm'),
            ],
          ),
        ),
      ]),
    );
  }
}
