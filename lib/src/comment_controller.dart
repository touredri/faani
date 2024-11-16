import 'package:faani/app/data/models/modele_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CommentController extends GetxController {
  final TextEditingController controller = TextEditingController();
  var isTyping = false.obs;
  var commentsStream = Stream<List<Comment>>.empty().obs;

  void onChanged(String text) {
    isTyping.value = text.isNotEmpty;
  }

  void clear() {
    controller.clear();
    isTyping.value = false;
  }

  void setCommentsStream(Stream<List<Comment>> stream) {
    commentsStream.value = stream;
  }
}