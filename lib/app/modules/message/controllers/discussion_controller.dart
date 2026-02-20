import 'dart:io';
import 'dart:async';
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
  final CollectionReference<Map<String, dynamic>> _rawCollection =
      FirebaseFirestore.instance.collection('messages');

  CollectionReference<Map<String, dynamic>> get collection => _rawCollection;

  CollectionReference<MsgContent> get messageCollection => _rawCollection
      .doc(doc_id.value)
      .collection('msglist')
      .withConverter<MsgContent>(
        fromFirestore: (snapshot, options) =>
            MsgContent.fromMap(snapshot, options),
        toFirestore: (MsgContent msg, options) => msg.toMap(),
      );

  final UserController userController = Get.find();
  final RxList<MsgContent> msgcontentlist = <MsgContent>[].obs;
  final RxString doc_id = ''.obs;
  final RxString to_id = ''.obs;
  final RxString to_name = ''.obs;
  final RxString to_avatar = ''.obs;
  final RxString modeleImage = ''.obs;
  final RxString token = ''.obs;
  StreamSubscription<QuerySnapshot<MsgContent>>? listener;
  final ScrollController msgScrolling = ScrollController();

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
    final messages = messageCollection.orderBy('addtime', descending: false);
    msgcontentlist.clear();
    listener = messages.snapshots().listen((event) {
      final items = event.docs
          .map((doc) => doc.data())
          .whereType<MsgContent>()
          .toList(growable: false);
      msgcontentlist.assignAll(items);
      _scrollToBottom();
    }, onError: (e) {
      print("Listing Error: $e");
    });
  }

  @override
  void onClose() {
    listener?.cancel();
    msgScrolling.dispose();
    super.onClose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!msgScrolling.hasClients) return;
      msgScrolling.animateTo(
        msgScrolling.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _updateThreadMeta(String lastMessage) async {
    await collection.doc(doc_id.value).update({
      'last_msg': lastMessage,
      'last_time': Timestamp.now(),
    });
  }

  Future<void> clearConversationMessages() async {
    final query = await messageCollection.get();
    if (query.docs.isEmpty) {
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    await _updateThreadMeta('');
    msgcontentlist.clear();
  }

  Future<void> deleteConversation() async {
    await clearConversationMessages();
    await collection.doc(doc_id.value).delete();
  }

  Future<void> uploadImage() async {
    if (imageFile == null) return;
    final fileName = '${randomString(10)}.${addExtension(imageFile!.path)}';
    try {
      final ref =
          FirebaseStorage.instance.ref('images').child('chats').child(fileName);
      await ref.putFile(imageFile!);
      final url = await ref.getDownloadURL();
      final content = MsgContent(
        id: user!.uid,
        content: url,
        type: 'image',
        addtime: Timestamp.now(),
      );
      await messageCollection.add(content);
      comment.clear();

      await _updateThreadMeta('New Image');
      _scrollToBottom();
    } on Exception catch (e) {
      print(e);
    } finally {
      imageFile = null;
    }
  }

  @override
  Future<void> sendMessageImage(String parentId) async {
    onSendLoading.value = true;
    try {
      final image = await getAndCropImage();
      if (image != null) {
        imageFile = File(image.path);
        await uploadImage();
      }
    } finally {
      onSendLoading.value = false;
    }
  }

  @override
  Future<void> sendMessageVoice(String parentId) async {
    onSendLoading.value = true;
    checkAudio();
    if (audioFile == null) {
      onSendLoading.value = false;
      return;
    }
    try {
      final ref = FirebaseStorage.instance
          .ref('audios')
          .child('chats')
          .child('${randomString(10)}.${addExtension(audioFile!.path)}');
      await ref.putFile(audioFile!);
      final url = await ref.getDownloadURL();
      final content = MsgContent(
        id: user!.uid,
        content: url,
        type: 'audio',
        addtime: Timestamp.now(),
      );
      await messageCollection.add(content);

      await _updateThreadMeta('message vocal');
      comment.clear();
      recordPath.value = '';
      onRecordStop();
      _scrollToBottom();
    } catch (e) {
      print("Failed to upload audio file: $e");
    } finally {
      onSendLoading.value = false;
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
      await messageCollection.add(content);

      await _updateThreadMeta(comment.text).then((value) => {
            sendNotification(
              token.value,
              'Nouveau message de ${userController.currentUser.value.nomPrenom}',
              comment.text,
            ),
            comment.clear(),
          });
      _scrollToBottom();
    }
    onSendLoading.value = false;
  }
}
