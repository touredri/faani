import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/message_modele.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DiscussionController extends GetxController {
  DiscussionController();
  final textEditingController = TextEditingController();
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

  sendMessage() async {
    if (textEditingController.text.isNotEmpty) {
      final content = MsgContent(
        id: user!.uid,
        content: textEditingController.text,
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
        'last_msg': textEditingController.text,
        'last_time': Timestamp.now(),
      }).then((value) => {
            sendNotification(
              token.value,
              'Nouveau message de ${userController.currentUser.value.nomPrenom}',
              textEditingController.text,
            ),
            textEditingController.clear(),
          });
    }
  }

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

  File? imageFile;
  final ImagePicker _picker = ImagePicker();

  void pickImageFromGallery() async {
    final pickImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      imageFile = File(pickImage.path);
      await uploadImage();
    } else {
      print('No image selected');
    }
  }

  void pickImageFromCamera() async {
    final pickImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickImage != null) {
      imageFile = File(pickImage.path);
      await uploadImage();
    } else {
      print('No image selected');
    }
  }

  // function that return random string
  String randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    final result =
        List.generate(length, (index) => chars[rnd.nextInt(chars.length)]);
    return result.join();
  }

  // function that add extension to the file
  String addExtension(String path) {
    final ext = path.split('.').last;
    return ext;
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
                  (value) => textEditingController.clear(),
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

  void recordVoice() {
    // implement recordVoice
  }
}
