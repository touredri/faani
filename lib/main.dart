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

  bool isTailleur = false;

  @override
  void initState() {
    show();
    _pages = [
      const HomePage(), // Page d'accueil
      const CommandePage(), // Page de commande
      const AjoutModele(), // Page ajout
      const FavoriesPage(), // Page de favories
      const ProfilePage(), // Page de profile
    ];
    super.initState();
  }

  final Map<String, dynamic> _user = {
    'name': 'John Doe',
    'email': 'dt@gmail.com',
    'profileImageUrl':
        'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png',
    'isCertify': true,
  };

  void show() {
    if (_user.containsKey('isCertify')) {
      setState(() {
        isTailleur = true;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Met à jour l'index de l'onglet sélectionné
    });
  }

  List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(height: 0),
        // landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType
            .fixed, // Affiche tous les éléments en permanence
        items: <BottomNavigationBarItem>[
          // Définit les éléments de la barre de navigation
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color(0xFF898888)),
            label: 'Accueil',
            activeIcon: Icon(Icons.home, color: primaryColor),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Color(0xFF898888)),
            label: 'Achats',
            activeIcon: Icon(Icons.shopping_cart, color: primaryColor),
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, -10),
              child: const Icon(
                Icons.add_circle_rounded,
                color: primaryColor,
                size: 45,
              ),
            ),
            label: 'Modele',
            activeIcon: Transform.translate(
              offset: const Offset(0, -10),
              child: const Icon(
                Icons.add_circle_rounded,
                color: primaryColor,
                size: 45,
              ),
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Color(0xFF898888)),
            label: 'Favoris',
            activeIcon: Icon(Icons.favorite, color: primaryColor),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFF898888)),
            label: 'Profile',
            activeIcon: Icon(Icons.person, color: primaryColor),
          ),
        ],
        currentIndex: _selectedIndex, // Index de l'élément sélectionné
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
