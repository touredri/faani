import 'package:faani/anonyme_profile.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/helpers/functions.dart';
import 'package:faani/pages/commande/commande.dart';
import 'package:faani/src/ajout_modele.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_state.dart';
import 'favorie_page.dart';
import 'pages/home/home.dart';
import 'my_theme.dart';
import 'profile_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // Index de l'onglet sélectionné
  late var _user;
  bool isTailleur = false;
  List<Widget> _pages = [];
  List<Widget> _clientPageList = [];

  // get isTailleur value from shared preferences
  void getIsTailleur() async {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    if (user!.isAnonymous) {
      return;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isTailleur = pref.getBool('isTailleur') ?? false;
    });
    if (isTailleur == true) {
      appState.changeTailleur = true;
    } else {
      appState.changeTailleur = false;
    }
  }

  // setup user variable to get user data from shared preferences
  Future<void> getUser(BuildContext context) async {
    if (user!.isAnonymous) {
      return;
    }

    _user = await loadObject('user');
    if (_user == null || _user.isEmpty) {
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (isTailleur) {
      await handleTailleur(uid, _user, context);
    } else {
      await handleClient(uid, _user, context);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(), // Page d'accueil
      const CommandePage(), // Page de commande
      user!.isAnonymous
          ? const AnonymeProfile()
          : const AjoutModele(), // Page ajout
      const FavoriesPage(), // Page de favories
      user!.isAnonymous
          ? const AnonymeProfile()
          : const ProfilePage(), // Page de profile
    ];
    _clientPageList = [
      const HomePage(), // Page d'accueil
      const CommandePage(), // Page de commande
      const FavoriesPage(), // Page de favories
      user!.isAnonymous
          ? const AnonymeProfile()
          : const ProfilePage(), // Page de profile
    ];
    getIsTailleur();
    getUser(context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Met à jour l'index de l'onglet sélectionné
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> clientitems = [
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
    ];
    List<BottomNavigationBarItem> items = [
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
        label: '',
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
    ];

    return Scaffold(
      body:
          isTailleur ? _pages[_selectedIndex] : _clientPageList[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(height: 0),
        // landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType
            .fixed, // Affiche tous les éléments en permanence
        items: isTailleur ? items : clientitems,
        currentIndex: _selectedIndex, // Index de l'élément sélectionné
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        selectedIconTheme: const IconThemeData(size: 30),
      ),
    );
  }
}