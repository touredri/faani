import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/models/user_role.dart';
import 'package:faani/app/data/services/access_control_service.dart';
import 'package:faani/app/data/services/getx_session_coordinator.dart';
import 'package:faani/app/data/services/session_coordinator.dart';
import 'package:faani/app/data/services/user_identity_binding_service.dart';
import 'package:faani/app/data/services/phone_otp_service.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/users_service.dart';
import '../../../firebase/global_function.dart';
import '../../home/controllers/user_controller.dart';
import '../views/otp_view.dart';
import '../views/sign_up_view.dart';

class AuthController extends GetxController {
  static const String _testPhoneNumber = '+22393734481';
  static const String _testOtpCode = '020202';
  static const String _googleWebClientId =
      '224443279523-jntqepgvi7kum1nvm81ru2ip27khkfar.apps.googleusercontent.com';
  static const Duration _googleAuthTimeout = Duration(seconds: 60);
  static const Duration _firebaseAuthTimeout = Duration(seconds: 45);
  static const Duration _firestoreReadTimeout = Duration(seconds: 30);
  static const Duration _deviceUpdateTimeout = Duration(seconds: 20);

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final UserIdentityBindingService _identityBindingService =
      UserIdentityBindingService();
  final PhoneOtpService _phoneOtpService = PhoneOtpService();
  late final SessionCoordinator _sessionCoordinator;
  RxString phoneNumber = ''.obs;
  RxString verificationId = ''.obs;
  RxBool isCodeSent = false.obs;
  RxString smsCode = ''.obs;
  RxBool loading = false.obs;
  RxBool isLoading = false.obs;
  RxBool googleLoading = false.obs;
  RxBool resend = false.obs;
  RxInt count = 60.obs;
  Timer? timer;
  TextEditingController smsCodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();
  final String defaultProfileImage = getRandomProfileImageUrl();

  AuthController({SessionCoordinator? sessionCoordinator}) {
    _sessionCoordinator =
        sessionCoordinator ?? GetxSessionCoordinator.standard();
  }

  // open url
  void openUrl(String link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // timer for resend sms code
  void decreaseCounter() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (count.value < 1) {
        timer?.cancel();
        count.value = 20;
        resend.value = true;
        return;
      }
      count.value--;
    });
  }

  // Function to initiate phone verification
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    loading.value = true;
    smsCodeController.clear();
    smsCode.value = '';
    try {
      if (kDebugMode && _isTestPhoneNumber(phoneNumber)) {
        verificationId.value = 'test-verification-id';
        isCodeSent.value = true;
        smsCodeController.text = _testOtpCode;
        smsCode.value = _testOtpCode;
        loading.value = false;
        Get.to(() => const OtpView());
        return;
      }

      // Firebase Phone Auth is intentionally not used here. AfrikSMS sends
      // the OTP through the callable function; Firebase only receives the
      // custom token after the code has been verified server-side.
      await _phoneOtpService.requestCode(phoneNumber);
      this.phoneNumber.value = phoneNumber;
      isCodeSent.value = true;
      loading.value = false;
      decreaseCounter();
      Get.to(() => const OtpView());
    } catch (e) {
      showCustomSnackbar(
        message: e.toString(),
        backgroundColor: Colors.red,
      );
      loading.value = false;
    }
  }

  // Function to resend sms code
  void onResendSmsCode() {
    smsCodeController.clear();
    resend.value = false;
    count.value = 60;
    decreaseCounter();
    verifyPhoneNumber(phoneNumber.value);
  }

  // Function to sign in with verification code
  Future<void> signInWithVerificationCode(String code) async {
    loading.value = true;
    try {
      if (kDebugMode && _isTestPhoneNumber(phoneNumber.value)) {
        if (code.trim() != _testOtpCode) {
          showCustomSnackbar(
            message: 'Code OTP de test invalide.',
            backgroundColor: Colors.red,
          );
          loading.value = false;
          return;
        }

        if (auth.currentUser == null) {
          await auth.signInAnonymously();
        }

        showCustomSnackbar(
            message: "Numéro de téléphone vérifié avec succès",
            backgroundColor: Colors.green);
        await _routeAfterSuccessfulAuth(fallbackPhoneNumber: _testPhoneNumber);
        loading.value = false;
        return;
      }

      final customToken = await _phoneOtpService.verifyCode(
        phoneNumber: phoneNumber.value,
        code: code,
      );
      await auth.signInWithCustomToken(customToken);
      showCustomSnackbar(
          message: "Numéro de téléphone vérifié avec succès",
          backgroundColor: Colors.green);
      await _routeAfterSuccessfulAuth();
      loading.value = false;
    } catch (e) {
      showCustomSnackbar(
        message: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
      loading.value = false;
    }
  }

  // check if user exists in firestore and return true
  Future<bool> checkUserExists() async {
    final UserService usersService = UserService();
    final UserModel? user = await usersService.getIfUser(auth.currentUser!.uid);
    if (user != null) {
      return true;
    }
    return false;
  }

  // auth anonymous
  Future<User?> signInAnonymously() async {
    try {
      final result = await auth.signInAnonymously();
      if (result.user != null) {
        debugPrint('User created successfully');
        setUser();
        return result.user;
      }
    } catch (e) {
      debugPrint(e.toString());
      debugPrint(
          'Failed to create user anonymously ! error: ************** $e **************');
    }
    return null;
  }

  // create user with its information
  void saveUserInFirestore(String number) async {
    if (nameController.text.length < 3) {
      showCustomSnackbar(
        message: "S'il vous plaît, entrez votre nom complet.",
        backgroundColor: Colors.red,
      );
      return;
    }
    loading.value = true;
    // link the name to the phone number
    await auth.currentUser!.updateDisplayName(
      nameController.text,
    );
    if (auth.currentUser!.photoURL == null ||
        auth.currentUser!.photoURL!.isEmpty) {
      await auth.currentUser!.updatePhotoURL(defaultProfileImage);
    }
    // Create a new user model
    final UserModel newUser = UserModel(
      id: auth.currentUser!.uid,
      nomPrenom: nameController.text,
      phoneNumber: number,
      role: AppUserRole.client,
      email: auth.currentUser!.email ?? '',
      adress: 'Bamako, Mali',
      profileImage: user!.photoURL ?? defaultProfileImage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    // Call the create user function from the users service
    final UserService usersService = UserService();
    usersService.createUser(newUser).then((value) {
      _bindIdentitySafely(
        phoneNumber: number,
        email: newUser.email ?? auth.currentUser?.email ?? '',
      );
      _bindCurrentDevice(newUser.id ?? auth.currentUser!.uid);
      // set the user to currentUser
      setUser();
      showCustomSnackbar(
        message: "Welcome ${newUser.nomPrenom} !",
        backgroundColor: Colors.green,
      );
      Get.offAllNamed(Routes.home, arguments: {'isNewUser': true});
      loading.value = false;
    }).catchError((error) {
      showCustomSnackbar(
        message: error.toString(),
        backgroundColor: Colors.red,
      );
    });
  }

  // get the user & set it to currentUser
  void setUser() async {
    final UserController userController = Get.find<UserController>();
    await userController.init();
  }

  Future<void> signOut() async {
    try {
      await _sessionCoordinator.closeFeatureScope();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isAdmin');

      final currentUid = auth.currentUser?.uid;
      if (currentUid != null && currentUid.isNotEmpty) {
        await prefs.remove('isAdmin_$currentUid');
      }
      await AccessControlService().clearCachedRoleForCurrentUser();

      Get.offAllNamed(Routes.auth);
      await Future.delayed(const Duration(milliseconds: 120));

      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      showCustomSnackbar(message: "Déconnecté avec succès");
    } catch (e) {
      showCustomSnackbar(message: e.toString());
    }
  }

  @override
  void onReady() {
    super.onReady();
    decreaseCounter();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  void updateUserName({String number = ''}) async {
    await auth.currentUser!.updateDisplayName(
      nameController.text,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({
      'nomPrenom': nameController.text,
      'phoneNumber': number,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _bindIdentitySafely(
      phoneNumber: number,
      email: auth.currentUser?.email ?? '',
    );
    await _bindCurrentDevice(auth.currentUser!.uid);
    showCustomSnackbar(
      message: "Welcome ${nameController.text} !",
      backgroundColor: Colors.green,
    );
    setUser();
    Get.offAllNamed(Routes.home);
  }

// Connexion avec Google
  Future<void> signInWithGoogle() async {
    if (googleLoading.value) return;

    googleLoading.value = true;
    debugPrint('[Auth][Google] Starting Google sign-in');
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: _googleWebClientId,
      );
      debugPrint('[Auth][Google] Opening account picker');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('[Auth][Google] Account picker cancelled');
        showCustomSnackbar(message: 'Connexion annulée.');
        return;
      }

      debugPrint('[Auth][Google] Account selected: ${googleUser.email}');
      debugPrint('[Auth][Google] Requesting Google authentication tokens');
      final GoogleSignInAuthentication googleAuth = await _withAuthTimeout(
        googleUser.authentication,
        timeout: _googleAuthTimeout,
        step: AuthTimeoutStep.googleTokens,
      );
      debugPrint('[Auth][Google] Tokens received: '
          'idToken=${googleAuth.idToken != null}, '
          'accessToken=${googleAuth.accessToken != null}');

      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw const AuthConfigurationException(
          'Google n\'a renvoyé ni idToken ni accessToken. '
          'Vérifie le client OAuth Web et les SHA Android dans Firebase.',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('[Auth][Google] Signing in with Firebase credential');
      final userCredential = await _withAuthTimeout(
        auth.signInWithCredential(credential),
        timeout: _firebaseAuthTimeout,
        step: AuthTimeoutStep.firebaseSignIn,
      );
      nameController.text = _resolveDisplayName(userCredential.user);
      phoneNumber.value = userCredential.user?.phoneNumber ?? '';
      if (auth.currentUser != null) {
        debugPrint('[Auth][Google] Firebase sign-in succeeded: '
            '${auth.currentUser!.uid}');
        debugPrint('[Auth][Google] Routing after successful auth');
        await _routeAfterSuccessfulAuth(fromGoogle: true);
        debugPrint('[Auth][Google] Routing completed');
        showCustomSnackbar(
            message: 'Connexion avec Google réussie !',
            backgroundColor: Colors.green);
      }
    } catch (e) {
      debugPrint('[Auth][Google] Sign-in failed: $e');
      showCustomSnackbar(
        message: _buildAuthErrorMessage(e, context: 'google'),
        backgroundColor: Colors.red,
      );
    } finally {
      googleLoading.value = false;
      debugPrint('[Auth][Google] Google sign-in flow ended');
    }
  }

  String _buildAuthErrorMessage(Object error, {required String context}) {
    if (error is FirebaseAuthException) {
      final code = error.code;
      final msg = (error.message ?? '').toLowerCase();

      if (code == 'too-many-requests') {
        return 'Trop de tentatives. Réessaie plus tard ou utilise un numéro de test Firebase.';
      }

      if (code == 'invalid-app-credential' ||
          code == '39' ||
          msg.contains('code 39') ||
          msg.contains('app credential')) {
        return 'Erreur code 39: échec de vérification de l\'application Android. '
            'Vérifie SHA-1/SHA-256 du certificat de signature (upload + Play App Signing) dans Firebase, '
            'puis télécharge un build récent. Un fallback reCAPTCHA a été tenté automatiquement.';
      }

      if (code == 'network-request-failed') {
        return 'Réseau indisponible. Vérifie la connexion internet puis réessaie.';
      }

      if (code == 'app-not-authorized' || code == 'operation-not-allowed') {
        final feature = context == 'phone'
            ? 'la connexion par téléphone'
            : context == 'google'
                ? 'la connexion Google'
                : 'cette méthode de connexion';
        return '$feature n\'est pas activée dans Firebase Console > Authentication > Sign-in method. '
            'Active le bon fournisseur, puis vérifie que l\'app Android com.touredri.faani est bien enregistrée '
            'avec la SHA-1/SHA-256 de la release.';
      }

      return error.message ?? 'Échec de connexion (${context.toUpperCase()}).';
    }

    if (error is PlatformException) {
      final all =
          '${error.code} ${error.message} ${error.details}'.toLowerCase();
      if (all.contains('apiexception: 10') ||
          all.contains('developer_error') ||
          all.contains('code 39')) {
        return 'Échec Google lié à la configuration OAuth Android. '
            'Vérifie le package com.touredri.faani, les SHA-1/SHA-256 Play App Signing '
            'et les clients OAuth dans Firebase/Google Cloud.';
      }
      return error.message ?? 'Erreur plateforme (${context.toUpperCase()}).';
    }

    if (error is AuthStepTimeoutException) {
      switch (error.step) {
        case AuthTimeoutStep.googleTokens:
          return 'Google n\'a pas renvoyé les jetons de connexion. '
              'Vérifie que les SHA Play App Signing sont bien dans Firebase, que Google est activé dans Authentication, '
              'puis réessaie avec un autre compte Google.';
        case AuthTimeoutStep.firebaseSignIn:
          return 'Firebase Auth ne finalise pas la connexion Google. '
              'Vérifie le fournisseur Google dans Firebase Authentication et les clients OAuth Android/Web.';
        case AuthTimeoutStep.firestoreProfile:
          return 'Connexion Google réussie, mais la récupération du profil prend trop de temps. '
              'Vérifie Firestore/App Check puis réessaie.';
        case AuthTimeoutStep.deviceUpdate:
          return 'Connexion Google réussie, mais la mise à jour de l\'appareil a pris trop de temps.';
      }
    }

    if (error is AuthConfigurationException) {
      return error.message;
    }

    if (error is TimeoutException) {
      return 'Une étape de connexion a pris trop de temps. Réessaie dans quelques secondes.';
    }

    return 'Erreur de connexion (${context.toUpperCase()}): $error';
  }

  String _resolveDisplayName(User? authUser) {
    final fromGoogle = authUser?.displayName?.trim() ?? '';
    if (fromGoogle.isNotEmpty) return fromGoogle;

    final fromEmail = authUser?.email?.split('@').first.trim() ?? '';
    if (fromEmail.isNotEmpty) return fromEmail;

    return 'Utilisateur Faani';
  }

  Future<void> _routeAfterSuccessfulAuth({
    bool fromGoogle = false,
    String? fallbackPhoneNumber,
  }) async {
    final currentUid = auth.currentUser?.uid;
    if (currentUid == null) return;

    final UserService usersService = UserService();
    debugPrint('[Auth] Reading Firestore user: $currentUid');
    final UserModel? existing = await _withAuthTimeout(
      usersService.getIfUser(currentUid),
      timeout: _firestoreReadTimeout,
      step: AuthTimeoutStep.firestoreProfile,
    );

    if (existing == null) {
      debugPrint('[Auth] No Firestore user found, opening sign-up');
      final authUser = auth.currentUser;
      final authPhone = (authUser?.phoneNumber ?? '').trim();
      nameController.text = _resolveDisplayName(authUser);
      phoneNumber.value =
          authPhone.isNotEmpty ? authPhone : (fallbackPhoneNumber ?? '').trim();
      Get.offAll(
        () => const SignUpView(),
        arguments: {
          'name': nameController.text,
          'phone': phoneNumber.value,
        },
      );
      return;
    }

    debugPrint('[Auth] Firestore user found, enforcing device policy');
    final isAllowed = await _enforceSingleDevicePolicy(existing);
    if (!isAllowed) return;

    final existingPhone = (existing.phoneNumber ?? '').trim();
    if (existingPhone.isNotEmpty) {
      await _bindIdentitySafely(
        phoneNumber: existingPhone,
        email: existing.email ?? auth.currentUser?.email ?? '',
      );
    } else {
      await _identityBindingService.syncCurrentUserIdentityFromFirestore();
    }

    final hasPhone = (existing.phoneNumber ?? '').trim().isNotEmpty;
    if (fromGoogle && !hasPhone) {
      debugPrint('[Auth] Existing Google user has no phone, opening sign-up');
      nameController.text = (existing.nomPrenom ?? '').trim().isNotEmpty
          ? existing.nomPrenom!.trim()
          : _resolveDisplayName(auth.currentUser);
      phoneNumber.value = '';
      Get.offAll(
        () => const SignUpView(),
        arguments: {
          'name': nameController.text,
          'phone': '',
        },
      );
      return;
    }

    debugPrint('[Auth] Opening home');
    setUser();
    Get.offAllNamed(Routes.home);
  }

  bool _isTestPhoneNumber(String value) {
    return value.trim() == _testPhoneNumber;
  }

  Future<bool> _enforceSingleDevicePolicy(UserModel existingUser) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return false;

    final currentDeviceId = await _getCurrentDeviceId();
    final currentDeviceLabel = await _getCurrentDeviceLabel();
    final savedDeviceId = (existingUser.activeDeviceId ?? '').trim();

    if (savedDeviceId.isNotEmpty && savedDeviceId != currentDeviceId) {
      showCustomSnackbar(
        message:
            'Session transférée vers cet appareil. L\'ancien téléphone sera déconnecté automatiquement.',
      );
    }

    try {
      await _withAuthTimeout(
        UserService().updateActiveDevice(
          uid: uid,
          deviceId: currentDeviceId,
          deviceLabel: currentDeviceLabel,
        ),
        timeout: _deviceUpdateTimeout,
        step: AuthTimeoutStep.deviceUpdate,
      );
    } catch (e) {
      debugPrint('[Auth] Active device update skipped: $e');
    }
    return true;
  }

  Future<void> _bindCurrentDevice(String uid) async {
    final currentDeviceId = await _getCurrentDeviceId();
    final currentDeviceLabel = await _getCurrentDeviceLabel();
    try {
      await _withAuthTimeout(
        UserService().updateActiveDevice(
          uid: uid,
          deviceId: currentDeviceId,
          deviceLabel: currentDeviceLabel,
        ),
        timeout: _deviceUpdateTimeout,
        step: AuthTimeoutStep.deviceUpdate,
      );
    } catch (e) {
      debugPrint('[Auth] Active device update skipped: $e');
    }
  }

  Future<String> _getCurrentDeviceId() async {
    try {
      final id = await FlutterUdid.consistentUdid;
      if (id.trim().isNotEmpty) {
        return id;
      }
    } catch (_) {}

    final fallback = auth.currentUser?.uid ?? DateTime.now().toIso8601String();
    return 'fallback-$fallback';
  }

  Future<String> _getCurrentDeviceLabel() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return '${info.brand} ${info.model}'.trim();
      }
      if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return '${info.name} ${info.model}'.trim();
      }
    } catch (_) {}
    return 'unknown-device';
  }

  Future<void> _bindIdentitySafely({
    required String phoneNumber,
    required String email,
  }) async {
    try {
      await _identityBindingService.bindCurrentUserIdentity(
        phoneNumber: phoneNumber,
        email: email,
      );
    } catch (e) {
      showCustomSnackbar(
        message: 'Vérification identité: ${e.toString()}',
        backgroundColor: Colors.orange,
      );
    }
  }

  Future<T> _withAuthTimeout<T>(
    Future<T> future, {
    required Duration timeout,
    required AuthTimeoutStep step,
  }) {
    return future.timeout(
      timeout,
      onTimeout: () => throw AuthStepTimeoutException(step),
    );
  }
}

enum AuthTimeoutStep {
  googleTokens,
  firebaseSignIn,
  firestoreProfile,
  deviceUpdate,
}

class AuthStepTimeoutException implements Exception {
  AuthStepTimeoutException(this.step);

  final AuthTimeoutStep step;

  @override
  String toString() => 'AuthStepTimeoutException($step)';
}

class AuthConfigurationException implements Exception {
  const AuthConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}
