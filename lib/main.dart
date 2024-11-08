import 'package:faani/app/firebase/push_notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/firebase/global_function.dart';
import 'app/modules/home/controllers/user_controller.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';
import 'generated/locales.g.dart';
import 'app/style/my_theme.dart';
import 'package:get/get.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider:
        ReCaptchaV3Provider('6LcToJ0pAAAAAChLT7Ao7VBy-nt5n56IcMoGi9Np'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  await initializePushNotifications();

  if (auth.currentUser != null) {
    final UserController userController = Get.put(UserController());
    await userController.init();
  }

  await initializeDateFormatting();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const FaaniApp());
  });
}

class FaaniApp extends StatelessWidget {
  const FaaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
    );
    return FlutterSpacer(
      builder: (BuildContext context) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Faani',
          theme: buildTheme(context),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          translationsKeys: AppTranslation.translations,
        );
      },
    );
  }
}
