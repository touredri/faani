import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/message_modele.dart';
import 'package:faani/app/data/services/commande_service.dart';
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
      .doc(docId.value)
      .collection('msglist')
      .withConverter<MsgContent>(
        fromFirestore: (snapshot, options) =>
            MsgContent.fromMap(snapshot, options),
        toFirestore: (MsgContent msg, options) => msg.toMap(),
      );

  final UserController userController = Get.find();
  final RxList<MsgContent> msgcontentlist = <MsgContent>[].obs;
  final RxString docId = ''.obs;
  final RxString toId = ''.obs;
  final RxString toName = ''.obs;
  final RxString toAvatar = ''.obs;
  final RxString modeleImage = ''.obs;
  final RxString token = ''.obs;
  final RxString commandeId = ''.obs;
  final RxString commandeTitle = ''.obs;
  final Rx<Commande?> commande = Rx<Commande?>(null);
  final RxBool isCommandeLoading = false.obs;
  StreamSubscription<QuerySnapshot<MsgContent>>? listener;
  final ScrollController msgScrolling = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      docId.value = args['doc_id'];
      toId.value = args['to_id'];
      toName.value = args['to_name'];
      toAvatar.value = args['to_avatar'];
      modeleImage.value = args['modele_img'];
      token.value = args['token'];
      commandeId.value = (args['commande_id'] ?? '').toString();
      commandeTitle.value = (args['commande_title'] ?? '').toString();
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
      debugPrint("Listing Error: $e");
    });
    markThreadAsRead();
    loadCommandeContext();
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
    await collection.doc(docId.value).update({
      'last_msg': lastMessage,
      'last_time': Timestamp.now(),
      'last_sender_id': user?.uid ?? '',
      'unread_for': FieldValue.arrayUnion([toId.value]),
    });
  }

  Future<void> markThreadAsRead() async {
    final currentUserId = user?.uid;
    if (currentUserId == null || docId.value.isEmpty) return;
    await collection.doc(docId.value).update({
      'unread_for': FieldValue.arrayRemove([currentUserId]),
    });
  }

  Future<void> loadCommandeContext() async {
    if (commandeId.value.isEmpty) return;
    isCommandeLoading.value = true;
    try {
      commande.value = await CommandeService().getCommande(commandeId.value);
    } catch (_) {
      commande.value = null;
    } finally {
      isCommandeLoading.value = false;
    }
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
    await collection.doc(docId.value).delete();
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
      debugPrint(e.toString());
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
      debugPrint("Failed to upload audio file: $e");
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
              category: 'message',
              targetType: 'discussion',
              targetId: docId.value,
            ),
            comment.clear(),
          });
      _scrollToBottom();
    }
    onSendLoading.value = false;
  }
}
