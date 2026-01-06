import 'package:faani/app/routes/app_pages.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:faani/generated/locales.g.dart';
import 'package:faani/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();
  _configureFirebaseAuthForDev();
  runApp(const MyApp());
}

void _configureFirebaseAuthForDev() {
  if (!kDebugMode) return;
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android) return;

  // Dev-only: bypass reCAPTCHA / Play Integrity during development.
  // For production, keep this disabled.
  FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
}

Future<void> _initFirebase() async {
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        break;
      default:
        // Firebase plugins are not guaranteed to support desktop targets.
        // Initialize without options and let feature code guard itself.
        await Firebase.initializeApp();
        break;
    }
  } catch (e) {
    debugPrint('Firebase init skipped/failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Faani',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      translationsKeys: AppTranslation.translations,
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
