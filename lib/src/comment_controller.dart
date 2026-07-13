import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/globale_widgets/message_field/message_field_controller.dart';
import 'package:faani/app/modules/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class CommentController extends MessageFieldController {
  var isTyping = false.obs;
  var commentsStream = Stream<List<Comment>>.empty().obs;
  final collection = FirebaseFirestore.instance.collection('modele');

  void onChanged(String text) {
    isTyping.value = text.isNotEmpty;
  }

  void clear() {
    comment.clear();
    isTyping.value = false;
  }

  void setCommentsStream(Stream<List<Comment>> stream) {
    commentsStream.value = stream;
  }

  @override
  Future<void> sendMessageImage(String parentId) async {
    onSendLoading.value = true;
    await getAndCropImage();
    if (imageFile == null) {
      onSendLoading.value = false;
      return;
    }
    final fileName = '${randomString(10)}.${addExtension(imageFile!.path)}';
    try {
      final ref = FirebaseStorage.instance
          .ref('images')
          .child('comments')
          .child(fileName);
      ref.putFile(imageFile!).whenComplete(() async {
        final url = await ref.getDownloadURL();
        final comment = Comment(
          idUser: user!.uid,
          comment: '',
          type: 'image',
          file: url,
          createdAt: Timestamp.fromDate(DateTime.now()),
        );
        await collection
            .doc(parentId)
            .collection('comments')
            .add(comment.toMap());
        clear();
      });
    } catch (e) {
      debugPrint(e.toString());
      onSendLoading.value = false;
    }
    imageFile = null;
    onSendLoading.value = false;
  }

  @override
  Future<void> sendMessageVoice(String parentId) async {
    checkAudio();
    final fileName = '${randomString(10)}.m4a';
    final ref = FirebaseStorage.instance
        .ref('audios')
        .child('comments')
        .child(fileName);
    try {
      ref.putFile(File(recordPath.value)).whenComplete(() async {
        final url = await ref.getDownloadURL();
        final comment = Comment(
          idUser: user!.uid,
          comment: '',
          type: 'audio',
          file: url,
          createdAt: Timestamp.fromDate(DateTime.now()),
        );
        await collection
            .doc(parentId)
            .collection('comments')
            .add(comment.toMap());
        clear();
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    onRecordStop();
    recordPath.value = '';
    onSendLoading.value = false;
  }

  @override
  Future<void> sendMessageText(String parentId) async {
    onSendLoading.value = true;
    if (comment.text.isNotEmpty) {
      final commentObjet = Comment(
        idUser: user!.uid,
        comment: comment.text,
        type: 'text',
        file: null,
        createdAt: Timestamp.fromDate(DateTime.now()),
      );
      await collection
          .doc(parentId)
          .collection('comments')
          .add(commentObjet.toMap());
      clear();
    }
    onSendLoading.value = false;
  }
}
