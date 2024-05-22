import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxString searchText = ''.obs;

  Stream<List<Modele>> searchResultsStream() async* {
    if (searchController.text.isEmpty) {
      print('empty');
      yield <Modele>[];
    } else {
      print('not empty');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('modele')
          .where('detail',
              isGreaterThanOrEqualTo: searchText.value.toLowerCase())
          .get();

      List<Modele> list = querySnapshot.docs.map((doc) {
        return Modele.fromDocumentSnapshot(doc);
      }).toList();

      yield list;
    }
  }

  void onTextChange(String text) {
    searchText.value = text;
    // print('searchText: $text');
  }

  @override
  void onInit() {
    super.onInit();
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
