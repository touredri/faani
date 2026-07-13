import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // connectivity_plus 6.0+ returns a List<ConnectivityResult>
    final bool online =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (isOnline.value != online) {
      isOnline.value = online;
      _showConnectivitySnackBar(online);
    }
  }

  void _showConnectivitySnackBar(bool online) {
    final context = Get.context;
    if (context == null) return;

    Get.snackbar(
      online ? 'Connexion rétablie' : 'Hors ligne',
      online
          ? 'Vous êtes de nouveau connecté.'
          : 'Vérifiez votre connexion internet.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: online ? Colors.green : Colors.red,
      colorText: Colors.white,
      icon: Icon(
        online ? Icons.wifi : Icons.wifi_off,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
    );
  }
}
