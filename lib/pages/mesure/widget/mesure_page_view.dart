import 'package:faani/app_state.dart';
import 'package:faani/constants/styles.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/models/mesure_model.dart';
import 'package:faani/pages/mesure/widget/page_view_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  }

  void onChangeBras(String value) {
    _brasController.text = value;
    setState(() {});
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
                                      Mesure newMesure = Mesure(
                                        bras: int.tryParse(
                                                _brasController.text) ??
                                            0,
                                        epaule: int.tryParse(
                                                _epauleController.text) ??
                                            0,
                                        hanche: int.tryParse(
                                                _hancheController.text) ??
                                            0,
                                        idUser: user!.uid,
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
                                      newMesure.create();
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
                          child: Text(
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
                          child: Text(
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