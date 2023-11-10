import 'package:faani/sign_in.dart';
import 'package:faani/sign_up.dart';
import 'package:faani/src/ajout_modele.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'commande_page.dart';
import 'favorie_page.dart';
import 'firebase_options.dart';

import 'home_page.dart';
import 'my_theme.dart';
import 'profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: (context, _) => MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: buildTheme(context),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // Index de l'onglet sélectionné
  PageController _pageController = PageController(); // Contrôleur de la page
  bool isTailleur = false;
  @override
  void dispose() {
    _pageController
        .dispose(); // Libère le contrôleur de la page lorsque le widget est supprimé
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    show();
  }

  final Map<String, dynamic> user = {
    'name': 'John Doe',
    'email': 'dt@gmail.com',
    'profileImageUrl':
        'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png',
    'isTailleur': true,
  };

  void show() {
    if (user.containsKey('isTailleur')) {
      setState(() {
        isTailleur = true;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Met à jour l'index de l'onglet sélectionné
      _pageController.jumpToPage(
          index); // Fait glisser le PageView à la page correspondante
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const <Widget>[
          HomePage(), // Page d'accueil
          CommandePage(), // Page de commande
          FavoriesPage(), // Page de favories
          ProfilePage(), // Page de profile
        ],
        onPageChanged: (index) {
          _onItemTapped(
              index); // Met à jour l'index lorsqu'une nouvelle page est affichée
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // Affiche tous les éléments en permanence
        items: const <BottomNavigationBarItem>[
          // Définit les éléments de la barre de navigation
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color(0xFF898888)),
            label: 'Accueil',
            activeIcon: Icon(Icons.home, color: primaryColor),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Color(0xFF898888)),
            label: 'Commandes',
            activeIcon: Icon(Icons.shopping_cart, color: primaryColor),
          ),
          // BottomNavigationBarItem(
          //     icon: SizedBox(width: 24, height: 24), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Color(0xFF898888)),
            label: 'Favoris',
            activeIcon: Icon(Icons.favorite, color: primaryColor),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFF898888)),
            label: 'Profile',
            activeIcon: Icon(Icons.person, color: primaryColor),
          ),
        ],
        currentIndex: _selectedIndex, // Index de l'élément sélectionné
        selectedItemColor:
            Colors.amber[800],
        onTap:
            _onItemTapped,
      ),
      floatingActionButton: isTailleur
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AjoutModele()),
                );
              },
              backgroundColor: primaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
