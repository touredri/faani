import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  final RxBool isSearching = false.obs;
  final count = 0.obs;

  void onSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      textEditingController.clear();
    }
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

  void increment() => count.value++;
}
