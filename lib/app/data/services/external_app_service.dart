import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalAppService {
  const ExternalAppService();

  static const storeUrl =
      'https://play.google.com/store/apps/details?id=com.touredri.faani';

  Future<void> rateApp() async {
    if (Platform.isAndroid) await launchUrl(Uri.parse(storeUrl));
  }

  Future<void> shareApp() => Share.share(storeUrl);
}
