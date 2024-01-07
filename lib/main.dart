import 'package:faani/navigation.dart';
import 'package:faani/pages/authentification/sign_up.dart';
import 'package:faani/pages/commande/commande.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
// import 'commande_page.dart';
import 'firebase_options.dart';
import 'my_theme.dart';
import 'pages/authentification/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => MyApp(),
    ));
  });
}

final _auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Faani',
      theme: buildTheme(context),
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
