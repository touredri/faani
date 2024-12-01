import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/modules/authentification/views/authentification_view.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/home/views/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/users_service.dart';
import '../../../firebase/global_function.dart';
import '../../home/controllers/user_controller.dart';
import '../views/otp_view.dart';
import '../views/sign_up_view.dart';

class AuthController extends GetxController {
  RxString phoneNumber = ''.obs;
  RxString verificationId = ''.obs;
  RxBool isCodeSent = false.obs;
  RxString smsCode = ''.obs;
  RxBool loading = false.obs;
  RxBool isLoading = false.obs;
  RxBool resend = false.obs;
  RxInt count = 60.obs;
  late Timer timer;
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
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (count.value < 1) {
        timer.cancel();
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
      FirebaseAuth.instance.setLanguageCode('en');
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Handle successful automatic verification
          // await auth.signInWithCredential(credential);
          await FirebaseAuth.instance.currentUser!
              .linkWithCredential(credential);
          Get.snackbar(
            "Success",
            "Phone number verified!",
            snackPosition: SnackPosition.BOTTOM,
          );

          Get.to(() => const SignUpView());
        },
        verificationFailed: (FirebaseAuthException e) {
          // print('********** ${e.message.toString()} **********');
          Get.snackbar(
            "Error",
            e.message.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
          isCodeSent.value = false;
          loading.value = false;
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verification ID and set code sent flag
          this.verificationId.value = verificationId;
          isCodeSent.value = true;
          loading.value = false;
          Get.to(() => const OtpView()); // navigate to otp view to enter code
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto-retrieval timeout
          this.verificationId.value = verificationId;
        },
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
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
      Get.offAll(() => const SignUpView());
      loading.value = false;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
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
      Get.snackbar(
        "Error",
        "S\'il vous plaît, entrez votre nom complet.",
        snackPosition: SnackPosition.BOTTOM,
        borderColor: Colors.red,
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
      email: auth.currentUser!.email ?? '',
      adress: 'Bamako, Mali',
      profileImage: user!.photoURL ?? defaultProfileImage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    // Call the create user function from the users service
    final UserService usersService = UserService();
    usersService.createUser(newUser).then((value) {
      // set the user to currentUser
      setUser();
      Get.snackbar(
        "Success",
        "Welcome ${newUser.nomPrenom} !",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAll(() => const HomeView(), arguments: {'isNewUser': true});
      loading.value = false;
    }).catchError((error) {
      Get.snackbar(
        "Error",
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  // get the user & set it to currentUser
  void setUser() async {
    final UserController userController = Get.put(UserController());
    await userController.init();
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const AuthView());
      showCustomSnackbar(message: "Déconnecté avec succès");
    } catch (e) {
      showCustomSnackbar(message: e.toString());
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    decreaseCounter();
  }

  @override
  void onClose() {
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
    });
    Get.snackbar(
      "Success",
      "Welcome ${nameController.text} !",
      snackPosition: SnackPosition.BOTTOM,
    );
    setUser();
    Get.offAll(() => const HomeView());
  }

// Connexion avec Google (inchangé)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Get.snackbar('Erreur', 'Connexion annulée.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCrendential = await auth.signInWithCredential(credential);
      nameController.text = userCrendential.user!.displayName!;
      phoneNumber.value = userCrendential.user!.phoneNumber ?? '';
      if (auth.currentUser != null) {
        final userExists = await checkUserExists();
        if (userExists) {
          setUser();
          Get.offAll(() => const HomeView());
        } else {
          Get.offAll(() => const SignUpView(), arguments: {
            'name': nameController.text,
            'phone': phoneNumber.value,
          });
        }
        Get.snackbar('Succès', 'Connexion avec Google réussie !');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Connexion avec Google échouée : $e');
    }
  }
}
