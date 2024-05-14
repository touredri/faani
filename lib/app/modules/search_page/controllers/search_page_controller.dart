import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxString searchText = ''.obs;

  Stream<List<Modele>> searchResultsStream() async* {
    if (searchController.text.isEmpty) {
      yield <Modele>[];
    } else {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('modele')
          .where('detail',
              isGreaterThanOrEqualTo: searchController.text.toLowerCase())
          .get();

      List<Modele> list = querySnapshot.docs.map((doc) {
        return Modele.fromDocumentSnapshot(doc);
      }).toList();

      yield list;
    }
  }

  void onTextChange(String text) {
    searchText.value = text;
    // update();
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
  }

  @override
  void onClose() {
    super.onClose();
  }
}
