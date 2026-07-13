import 'package:faani/app/data/services/connectivity/connectivity_service.dart';
import 'package:faani/app/routes/app_pages.dart';
import 'package:faani/app/style/app_theme.dart';
import 'package:faani/generated/locales.g.dart';
import 'package:faani/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

const bool _enableDebugAppCheck =
    bool.fromEnvironment('ENABLE_DEBUG_APP_CHECK', defaultValue: false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  Get.put(ConnectivityService());
  await _initIntl();
  await _initFirebase();
  _configureFirebaseAuthForDev();
  runApp(const MyApp());
}

Future<void> _initIntl() async {
  try {
    await initializeDateFormatting('fr_FR');
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('pt_BR');
    Intl.defaultLocale = 'fr_FR';
  } catch (e) {
    debugPrint('Intl locale init skipped/failed: $e');
  }
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

    if (kReleaseMode || _enableDebugAppCheck) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kReleaseMode
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
      );
      if (!kReleaseMode) {
        try {
          final token = await FirebaseAppCheck.instance.getToken();
          debugPrint('Firebase App Check Debug Token: $token');
        } catch (e) {
          debugPrint('Failed to get App Check token: $e');
        }
      }
    } else {
      debugPrint('Firebase App Check skipped for local debug build.');
    }
  } catch (e) {
    debugPrint('Firebase init skipped/failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: 'Faani',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          translationsKeys: AppTranslation.translations,
          fallbackLocale: const Locale('en', 'US'),
          builder: (context, widget) {
            final theme = Theme.of(context);
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: theme.brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              child: widget ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
