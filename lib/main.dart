import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/anonyme_profile.dart';
import 'package:faani/auth.dart';
import 'package:faani/client_commande_page.dart';
import 'package:faani/sign_in.dart';
import 'package:faani/sign_up.dart';
import 'package:faani/src/ajout_mesure.dart';
import 'package:faani/src/ajout_modele.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_state.dart';
import 'commande_page.dart';
import 'favorie_page.dart';
import 'firebase_options.dart';

import 'home_page.dart';
import 'modele/classes.dart';
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

final _auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: buildTheme(context),
      // home: const Home(),
      initialRoute: '/',
      routes: {
        '/': (context) =>
            _auth.currentUser != null ? const Home() : const SignInPage(),
        '/sign_in': (context) => const SignInPage(),
        '/sign_up': (context) => const SignUp(),
        '/commande': (context) => const CommandePage(),
      },
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
  late var _user;
  bool isTailleur = false;
  List<Widget> _pages = [];
  List<Widget> _clientPageList = [];

  // get isTailleur value from shared preferences
  void getIsTailleur() async {
    if (user!.isAnonymous) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTailleur = prefs.getBool('isTailleur') ?? false;
    });
    if (isTailleur == true) {
      Provider.of<ApplicationState>(context, listen: false).changeTailleur =
          true;
    }
  }

  // setup user variable to get user data from shared preferences
  void getUser() async {
    // if(user != null) {
    if (user!.isAnonymous) {
      return;
      // }
    }
    _user = await loadObject('user');
    if (isTailleur == true) {
      DocumentReference<Object?> docRef = FirebaseFirestore.instance
          .collection('Tailleur')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      Tailleur tailleur = Tailleur.fromMap(_user, docRef);
      Provider.of<ApplicationState>(context, listen: false)
          .changeCurrentTailleur = tailleur;
    } else {
      DocumentReference<Object?> docRef = FirebaseFirestore.instance
          .collection('client')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      Client client = Client.fromMap(_user, docRef);
      Provider.of<ApplicationState>(context, listen: false)
          .changeCurrentClient = client;
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
      const ClientCommandePage(), // Page de commande
      const FavoriesPage(), // Page de favories
      user!.isAnonymous
          ? const AnonymeProfile()
          : const ProfilePage(), // Page de profile
    ];
    getUser();
    getIsTailleur();
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
    ];

    return Scaffold(
      body:
          isTailleur ? _pages[_selectedIndex] : _clientPageList[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(height: 0),
        // landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType
            .fixed, // Affiche tous les éléments en permanence
        items: isTailleur ? items : clientitems,
        currentIndex: _selectedIndex, // Index de l'élément sélectionné
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
