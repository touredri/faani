import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/modules/home/views/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  RxBool resend = false.obs;
  RxInt count = 60.obs;
  late Timer timer;
  TextEditingController smsCodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
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
      loading.value = false;
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
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
      await auth.signInWithCredential(credential);
      Get.snackbar(
        "Success",
        "Successfully signed in!",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.to(() =>
          const SignUpView()); // navigate to sign up view after successful sign in
      loading.value = false;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
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

  // create user with its information
  void saveUserInFirestore() async {
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
      phoneNumber: phoneNumber.value,
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
      Get.to(() => HomeView());
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

  @override
  void onInit() {
    super.onInit();
    if (Get.find<ConnectivityController>().isOnline.value == false) {
      Get.snackbar(
          'Pas d\'accès internet ', 'Please check your internet connection',
          snackPosition: SnackPosition.TOP);
    }
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

  void updateUserName() async {
    await auth.currentUser!.updateDisplayName(
      nameController.text,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({
      'nomPrenom': nameController.text,
    });
    Get.snackbar(
      "Success",
      "Welcome ${nameController.text} !",
      snackPosition: SnackPosition.BOTTOM,
    );
    setUser();
    Get.to(() => HomeView());
  }
}
