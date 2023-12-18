import 'package:faani/app_state.dart';
import 'package:faani/controllers/categorie_controller.dart';
import 'package:faani/controllers/modele_controller.dart';
import 'package:faani/models/categorie_model.dart';
import 'package:faani/pages/home/widget/filtered_container.dart';
import 'package:faani/src/explore.dart';
import 'package:faani/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'src/home_item_list.dart';
import '../../firebase_get_all_data.dart';
import '../../models/modele_model.dart';
import 'widget/home_pageView.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _homeState();
}

class _homeState extends State<HomePage> {
  bool isHommeSelected = true;
  bool isFemmeSelected = false;
  String currentFilterSelected = 'Tous';
  List<Modele> modeles = <Modele>[];
  List<Categorie> listCategorie = <Categorie>[];
  CategorieController category = CategorieController();
  ModeleController modeleController = ModeleController(); 

  // filter modele by category
  void changeFilter(String newFilter) {
    listCategorie =
        Provider.of<ApplicationState>(context, listen: false).categorie;
    setState(() {
      currentFilterSelected = newFilter;
      getAllModeles().listen((event) {
        setState(() {
          modeles = event.where((modele) {
            if (currentFilterSelected == 'Tous') {
              if (isHommeSelected) {
                return modele.genreHabit == 'Homme';
              } else if (isFemmeSelected) {
                return modele.genreHabit == 'Femme';
              }
              return true;
            } else if (isHommeSelected) {
              return modele.idCategorie ==
                      listCategorie
                          .where((element) =>
                              element.libelle == currentFilterSelected)
                          .first
                          .id &&
                  modele.genreHabit == 'Homme';
            } else {
              return modele.idCategorie ==
                      listCategorie
                          .where((element) =>
                              element.libelle == currentFilterSelected)
                          .first
                          .id &&
                  modele.genreHabit == 'Femme';
            }
          }).toList();
        });
      });
    });
  }

  // change filter homme/femme
  void genreFilter() {
    setState(() {
      if (isHommeSelected) {
        modeles =
            modeles.where((modele) => modele.genreHabit == 'Homme').toList();
      } else if (isFemmeSelected) {
        modeles =
            modeles.where((modele) => modele.genreHabit == 'Femme').toList();
      }
      changeFilter(currentFilterSelected);
    });
  }

  @override
  void initState() {
    super.initState();
    category.getCategorie(context);
    modeleController.getAllModeles(context);
    getAllModeles().listen((event) {
      setState(() {
        modeles = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    listCategorie =
        Provider.of<ApplicationState>(context, listen: false).categorie;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Faani',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    isHommeSelected = true;
                    isFemmeSelected = false;
                    genreFilter();
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
                    isHommeSelected = false;
                    isFemmeSelected = true;
                    genreFilter();
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => const ExplorePage()));
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
                  myFilterContainer('Tous', () => changeFilter('Tous'),
                      currentFilterSelected),
                  for (var categorie in listCategorie)
                    myFilterContainer(
                        categorie.libelle,
                        () => changeFilter(categorie.libelle),
                        currentFilterSelected),
                ],
              ),
            )
          ]),
          HomePAgeView(
            modeles: modeles,
          ),
        ],
      ),
    );
  }
}
