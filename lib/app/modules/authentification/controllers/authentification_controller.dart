import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/models/user_role.dart';
import 'package:faani/app/data/services/access_control_service.dart';
import 'package:faani/app/data/services/user_identity_binding_service.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../../home/controllers/home_controller.dart';
import '../../accueil/controllers/accueil_controller.dart';
import '../../commande/controllers/commande_controller.dart';
import '../../favorie/controllers/favorie_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../views/otp_view.dart';
import '../views/sign_up_view.dart';

class AuthController extends GetxController {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final UserIdentityBindingService _identityBindingService =
      UserIdentityBindingService();
  RxString phoneNumber = ''.obs;
  RxString verificationId = ''.obs;
  RxBool isCodeSent = false.obs;
  RxString smsCode = ''.obs;
  RxBool loading = false.obs;
  RxBool isLoading = false.obs;
  RxBool resend = false.obs;
  RxInt count = 60.obs;
  bool _phoneVerificationRetriedWithRecaptcha = false;
  Timer? timer;
  TextEditingController smsCodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();
  final String defaultProfileImage = getRandomProfileImageUrl();

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
    try {
      FirebaseAuth.instance.setLanguageCode('fr');
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification succeeded (instant validation on some devices).
          if (auth.currentUser != null) {
            await auth.currentUser!.linkWithCredential(credential);
          } else {
            await auth.signInWithCredential(credential);
          }

          await _routeAfterSuccessfulAuth();
          _phoneVerificationRetriedWithRecaptcha = false;
          loading.value = false;
        },
        verificationFailed: (FirebaseAuthException e) async {
          if (_shouldRetryWithRecaptcha(e) &&
              !_phoneVerificationRetriedWithRecaptcha) {
            _phoneVerificationRetriedWithRecaptcha = true;
            await FirebaseAuth.instance.setSettings(forceRecaptchaFlow: true);
            await verifyPhoneNumber(phoneNumber);
            return;
          }

          showCustomSnackbar(
            message: _buildAuthErrorMessage(e, context: 'phone'),
            backgroundColor: Colors.red,
          );
          isCodeSent.value = false;
          loading.value = false;
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verification ID and set code sent flag
          this.verificationId.value = verificationId;
          isCodeSent.value = true;
          _phoneVerificationRetriedWithRecaptcha = false;
          loading.value = false;
          Get.to(() => const OtpView()); // navigate to otp view to enter code
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto-retrieval timeout
          this.verificationId.value = verificationId;
        },
      );
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
    _phoneVerificationRetriedWithRecaptcha = false;
    decreaseCounter();
    verifyPhoneNumber(phoneNumber.value);
  }

  // Function to sign in with verification code
  Future<void> signInWithVerificationCode(String code) async {
    loading.value = true;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: code,
      );
      if (auth.currentUser != null) {
        await auth.currentUser!.linkWithCredential(credential);
      } else {
        await auth.signInWithCredential(credential);
      }
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
        print('User created successfully');
        setUser();
        return result.user;
      }
    } catch (e) {
      debugPrint(e.toString());
      print(
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
      Get.offAllNamed(Routes.HOME, arguments: {'isNewUser': true});
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
      await _disposeHomeFlowControllers();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isAdmin');

      final currentUid = auth.currentUser?.uid;
      if (currentUid != null && currentUid.isNotEmpty) {
        await prefs.remove('isAdmin_$currentUid');
      }
      await AccessControlService().clearCachedRoleForCurrentUser();

      Get.offAllNamed(Routes.AUTH);
      await Future.delayed(const Duration(milliseconds: 120));

      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      showCustomSnackbar(message: "Déconnecté avec succès");
    } catch (e) {
      showCustomSnackbar(message: e.toString());
    }
  }

  Future<void> _disposeHomeFlowControllers() async {
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }
    if (Get.isRegistered<CommandeController>()) {
      Get.delete<CommandeController>(force: true);
    }
    if (Get.isRegistered<FavorieController>()) {
      Get.delete<FavorieController>(force: true);
    }
    if (Get.isRegistered<AccueilController>()) {
      Get.delete<AccueilController>(force: true);
    }
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
    }
    if (Get.isRegistered<UserController>()) {
      Get.delete<UserController>(force: true);
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
    Get.offAllNamed(Routes.HOME);
  }

// Connexion avec Google (inchangé)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        showCustomSnackbar(message: 'Connexion annulée.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCrendential = await auth.signInWithCredential(credential);
      nameController.text = _resolveDisplayName(userCrendential.user);
      phoneNumber.value = userCrendential.user?.phoneNumber ?? '';
      if (auth.currentUser != null) {
        await _routeAfterSuccessfulAuth(fromGoogle: true);
        showCustomSnackbar(
            message: 'Connexion avec Google réussie !',
            backgroundColor: Colors.green);
      }
    } catch (e) {
      showCustomSnackbar(
        message: _buildAuthErrorMessage(e, context: 'google'),
        backgroundColor: Colors.red,
      );
    }
  }

  bool _shouldRetryWithRecaptcha(FirebaseAuthException e) {
    final code = e.code.toLowerCase();
    final msg = (e.message ?? '').toLowerCase();
    return code.contains('invalid-app-credential') ||
        code == '39' ||
        msg.contains('code 39') ||
        msg.contains('invalid app credential') ||
        msg.contains('app credential');
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
        return 'Cette méthode de connexion n\'est pas autorisée dans Firebase Console pour ce projet.';
      }

      return error.message ?? 'Échec de connexion (${context.toUpperCase()}).';
    }

    if (error is PlatformException) {
      final all =
          '${error.code} ${error.message} ${error.details}'.toLowerCase();
      if (all.contains('apiexception: 10') ||
          all.contains('developer_error') ||
          all.contains('code 39')) {
        return 'Échec Google/Phone Auth lié à la configuration OAuth Android. '
            'Vérifie le package, SHA-1/SHA-256 et les clients OAuth dans Firebase/Google Cloud.';
      }
      return error.message ?? 'Erreur plateforme (${context.toUpperCase()}).';
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

  Future<void> _routeAfterSuccessfulAuth({bool fromGoogle = false}) async {
    final currentUid = auth.currentUser?.uid;
    if (currentUid == null) return;

    final UserService usersService = UserService();
    final UserModel? existing = await usersService.getIfUser(currentUid);

    if (existing == null) {
      final authUser = auth.currentUser;
      nameController.text = _resolveDisplayName(authUser);
      phoneNumber.value = authUser?.phoneNumber ?? '';
      Get.offAll(
        () => const SignUpView(),
        arguments: {
          'name': nameController.text,
          'phone': phoneNumber.value,
        },
      );
      return;
    }

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

    setUser();
    Get.offAllNamed(Routes.HOME);
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

    await UserService().updateActiveDevice(
      uid: uid,
      deviceId: currentDeviceId,
      deviceLabel: currentDeviceLabel,
    );
    return true;
  }

  Future<void> _bindCurrentDevice(String uid) async {
    final currentDeviceId = await _getCurrentDeviceId();
    final currentDeviceLabel = await _getCurrentDeviceLabel();
    await UserService().updateActiveDevice(
      uid: uid,
      deviceId: currentDeviceId,
      deviceLabel: currentDeviceLabel,
    );
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
}
