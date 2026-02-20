import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/message_modele.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/message/views/discussion_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class MessageController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final CollectionReference<Map<String, dynamic>> _rawCollection =
      FirebaseFirestore.instance.collection('messages');

  CollectionReference<MessageModel> get collection =>
      _rawCollection.withConverter<MessageModel>(
        fromFirestore: (snapshot, options) =>
            MessageModel.fromMap(snapshot, options),
        toFirestore: (MessageModel msg, options) => msg.toMap(),
      );
  final RxString modeleImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    textEditingController.addListener(_onSearchTextChanged);
  }

  @override
  void onClose() {
    textEditingController.removeListener(_onSearchTextChanged);
    textEditingController.dispose();
    super.onClose();
  }

  void _onSearchTextChanged() {
    searchQuery.value = textEditingController.text.trim().toLowerCase();
  }

  void onSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      textEditingController.clear();
      searchQuery.value = '';
    }
  }

  void toggleSearch() {
    onSearch();
    update(['search']);
  }

  Stream<List<MessageModel>> getMessages() {
    final currentUserId = user?.uid;
    if (currentUserId == null) {
      return Stream.value(<MessageModel>[]);
    }

    Stream<List<MessageModel>> fromStream = collection
        .where('from_id', isEqualTo: user!.uid)
        .orderBy('last_time', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());

    Stream<List<MessageModel>> toStream = collection
        .where('to_id', isEqualTo: user!.uid)
        .orderBy('last_time', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());

    return CombineLatestStream.combine2(
      fromStream,
      toStream,
      (List<MessageModel> list1, List<MessageModel> list2) {
        final merged = <String, MessageModel>{};
        for (final message in [...list1, ...list2]) {
          final fromId = message.from_id ?? '';
          final toId = message.to_id ?? '';
          if (fromId.isEmpty || toId.isEmpty) {
            continue;
          }
          final key =
              fromId.compareTo(toId) <= 0 ? '$fromId|$toId' : '$toId|$fromId';
          final previous = merged[key];
          if (previous == null) {
            merged[key] = message;
            continue;
          }
          final previousTime = previous.last_time?.millisecondsSinceEpoch ?? 0;
          final currentTime = message.last_time?.millisecondsSinceEpoch ?? 0;
          if (currentTime > previousTime) {
            merged[key] = message;
          }
        }

        final result = merged.values.toList()
          ..sort(
            (a, b) => (b.last_time?.millisecondsSinceEpoch ?? 0)
                .compareTo(a.last_time?.millisecondsSinceEpoch ?? 0),
          );
        return result;
      },
    );
  }

  List<MessageModel> filterMessages(List<MessageModel> messages) {
    final query = searchQuery.value;
    if (query.isEmpty) {
      return messages;
    }

    return messages.where((message) {
      final fromName = (message.from_name ?? '').toLowerCase();
      final toName = (message.to_name ?? '').toLowerCase();
      final lastMsg = (message.last_msg ?? '').toLowerCase();
      return fromName.contains(query) ||
          toName.contains(query) ||
          lastMsg.contains(query);
    }).toList();
  }

  Future<void> goChat(UserModel toUser, {String modeleImg = ''}) async {
    final currentUser = user;
    if (currentUser == null) {
      return;
    }

    final fromMessage = await collection
        .where('from_id', isEqualTo: user!.uid)
        .where('to_id', isEqualTo: toUser.id)
        .get();

    final toMessage = await collection
        .where('from_id', isEqualTo: toUser.id)
        .where('to_id', isEqualTo: user!.uid)
        .get();

    final existingDocId = fromMessage.docs.isNotEmpty
        ? fromMessage.docs.first.id
        : (toMessage.docs.isNotEmpty ? toMessage.docs.first.id : null);

    if (existingDocId != null) {
      _openDiscussion(
        docId: existingDocId,
        toUser: toUser,
        modeleImg: modeleImg,
      );
      return;
    }

    if (modeleImg.isEmpty) {
      Get.snackbar(
        'Information',
        'Veuillez sélectionner un modèle pour démarrer',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final msgData = MessageModel(
      from_avatar: currentUser.photoURL ?? '',
      from_name: currentUser.displayName,
      from_id: currentUser.uid,
      to_avatar: toUser.profileImage,
      to_name: toUser.nomPrenom,
      to_id: toUser.id,
      modele_img: modeleImg,
      message: '',
      last_msg: '',
      last_time: Timestamp.now(),
      msg_num: 0,
    );

    final created = await collection.add(msgData);
    _openDiscussion(
      docId: created.id,
      toUser: toUser,
      modeleImg: modeleImg,
    );
  }

  void _openDiscussion({
    required String docId,
    required UserModel toUser,
    required String modeleImg,
  }) {
    Get.to(
      () => const DiscussionView(),
      transition: Transition.rightToLeftWithFade,
      arguments: {
        'doc_id': docId,
        'to_id': toUser.id,
        'to_name': toUser.nomPrenom,
        'to_avatar': toUser.profileImage,
        'modele_img': modeleImg,
        'token': toUser.token,
      },
    );
  }
}
