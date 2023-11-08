import 'package:faani/sign_in.dart';
import 'package:faani/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'firebase_options.dart';

import 'home_page.dart';
import 'my_theme.dart';

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
        controller: _pageController, // Utilise le contrôleur de la page
        children: const <Widget>[
          HomePage(), // Page d'accueil
          //   MessagesPage(), // Page de messages
          // FavorisPage(), // Page de favoris
          //  ProfilePage(), // Page de profil
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
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Color(0xFF898888)),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Color(0xFF898888)),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFF898888)),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Index de l'élément sélectionné
        selectedItemColor:
            Colors.amber[800], // Couleur de l'élément sélectionné
        onTap:
            _onItemTapped, // Appelé lorsque l'utilisateur appuie sur un élément de la barre de navigation
      ),
      floatingActionButton: isTailleur
          ? FloatingActionButton(
              onPressed: () {
                // Action à effectuer lorsque l'utilisateur appuie sur le bouton d'ajout
                // show();
              },
              backgroundColor: primaryColor, // Couleur de fond du bouton
              child: const Icon(
                Icons.add,
                color: Colors.white, // Couleur de l'icône du bouton
              ),
            )
          : SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
