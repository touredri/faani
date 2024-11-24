import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/message_modele.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/message_field/message_field_controller.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscussionController extends MessageFieldController {
  DiscussionController();
  final collection = FirebaseFirestore.instance.collection('messages');
  final UserController userController = Get.find();
  final RxList<MsgContent> msgcontentlist = <MsgContent>[].obs;
  final RxString doc_id = ''.obs;
  final RxString to_id = ''.obs;
  final RxString to_name = ''.obs;
  final RxString to_avatar = ''.obs;
  final RxString modeleImage = ''.obs;
  final RxString token = ''.obs;
  var listener;
  ScrollController msgScrolling = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      doc_id.value = args['doc_id'];
      to_id.value = args['to_id'];
      to_name.value = args['to_name'];
      to_avatar.value = args['to_avatar'];
      modeleImage.value = args['modele_img'];
      token.value = args['token'];
    }
  }

  @override
  void onReady() {
    super.onReady();
    var messages = collection
        .doc(doc_id.value)
        .collection('msglist')
        .withConverter(
          fromFirestore: MsgContent.fromMap,
          toFirestore: (MsgContent msg, options) => msg.toMap(),
        )
        .orderBy("addtime", descending: false);
    msgcontentlist.clear();
    listener = messages.snapshots().listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            if (change.doc.data() != null) {
              msgcontentlist.insert(0, change.doc.data()!);
            }
            break;
          case DocumentChangeType.modified:
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
    }, onError: (e) {
      print("Listing Error: $e");
    });
  }

  @override
  void dispose() {
    listener.cancel();
    msgScrolling.dispose();
    super.dispose();
  }

  Future uploadImage() async {
    if (imageFile == null) return;
    final fileName = '${randomString(10)}.${addExtension(imageFile!.path)}';
    try {
      final ref = FirebaseStorage.instance.ref('chatImages').child(fileName);
      ref.putFile(imageFile!).snapshotEvents.listen((event) async {
        switch (event.state) {
          case TaskState.success:
            final url = await ref.getDownloadURL();
            final content = MsgContent(
              id: user!.uid,
              content: url,
              type: 'image',
              addtime: Timestamp.now(),
            );
            await collection
                .doc(doc_id.value)
                .collection('msglist')
                .withConverter(
                    fromFirestore: MsgContent.fromMap,
                    toFirestore: (MsgContent msg, options) => msg.toMap())
                .add(content)
                .then(
                  (value) => comment.clear(),
                );

            await collection.doc(doc_id.value).update({
              'last_msg': 'New Image',
              'last_time': Timestamp.now(),
            });
            break;
          case TaskState.running:
            break;
          case TaskState.paused:
            break;
          case TaskState.canceled:
            break;
          case TaskState.error:
            break;
        }
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Future<void> sendMessageImage(String parentId) async {
    onSendLoading.value = true;
    final image = await getAndCropImage();
    if (image != null) {
      imageFile = File(image.path);
      await uploadImage();
    }
    onSendLoading.value = false;
  }

  @override
  Future<void> sendMessageVoice(String parentId) async {
    checkAudio();
    try {
      final ref = FirebaseStorage.instance
          .ref('chatAudios')
          .child('${randomString(10)}.${addExtension(audioFile!.path)}');
      await ref.putFile(audioFile!).whenComplete(() async {
        final url = await ref.getDownloadURL();
        final content = MsgContent(
          id: user!.uid,
          content: url,
          type: 'audio',
          addtime: Timestamp.now(),
        );
        await collection
            .doc(doc_id.value)
            .collection('msglist')
            .withConverter(
                fromFirestore: MsgContent.fromMap,
                toFirestore: (MsgContent msg, options) => msg.toMap())
            .add(content)
            .then(
          (value) {
            comment.clear();
            recordPath.value = '';
          },
        );

        await collection.doc(doc_id.value).update({
          'last_msg': 'message vocal',
          'last_time': Timestamp.now(),
        });
      });
      onRecordStop();
    } catch (e) {
      print("Failed to upload audio file: $e");
    }
  }

  @override
  Future<void> sendMessageText(String parentId) async {
    onSendLoading.value = true;
    if (comment.text.isNotEmpty) {
      final content = MsgContent(
        id: user!.uid,
        content: comment.text,
        type: 'text',
        addtime: Timestamp.now(),
      );
      await collection
          .doc(doc_id.value)
          .collection('msglist')
          .withConverter(
              fromFirestore: MsgContent.fromMap,
              toFirestore: (MsgContent msg, options) => msg.toMap())
          .add(content);

      await collection.doc(doc_id.value).update({
        'last_msg': comment.text,
        'last_time': Timestamp.now(),
      }).then((value) => {
            sendNotification(
              token.value,
              'Nouveau message de ${userController.currentUser.value.nomPrenom}',
              comment.text,
            ),
            comment.clear(),
          });
    }
    onSendLoading.value = false;
  }
}
