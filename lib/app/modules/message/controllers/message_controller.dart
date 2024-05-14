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
  final count = 0.obs;
  final collection = FirebaseFirestore.instance.collection('messages');
  final RxString modeleImage = ''.obs;

  void onSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      textEditingController.clear();
    }
  }

  Stream<List<MessageModel>> getMessages() {
    // Query where 'from_id' is equal to 'user!.uid'
    Stream<List<MessageModel>> fromStream = collection
        .withConverter(
            fromFirestore: MessageModel.fromMap,
            toFirestore: (MessageModel msg, options) => msg.toMap())
        .where('from_id', isEqualTo: user!.uid)
        .orderBy('last_time', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());

    // Query where 'to_id' is equal to 'user!.uid'
    Stream<List<MessageModel>> toStream = collection
        .withConverter(
            fromFirestore: MessageModel.fromMap,
            toFirestore: (MessageModel msg, options) => msg.toMap())
        .where('to_id', isEqualTo: user!.uid)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());

    // Merge the two streams
    return CombineLatestStream.combine2(fromStream, toStream,
        (List<MessageModel> list1, List<MessageModel> list2) {
      return list1 + list2;
    });
  }

  void goChat(UserModel to_user, {String modeleImg = ''}) async {
    var from_message = await collection
        .withConverter(
            fromFirestore: MessageModel.fromMap,
            toFirestore: (MessageModel msg, options) => msg.toMap())
        .where('from_id', isEqualTo: user!.uid)
        .where('to_id', isEqualTo: to_user.id)
        .get();

    var to_message = await collection
        .withConverter(
            fromFirestore: MessageModel.fromMap,
            toFirestore: (MessageModel msg, options) => msg.toMap())
        .where('from_id', isEqualTo: to_user.id)
        .where('to_id', isEqualTo: user!.uid)
        .get();

    if (from_message.docs.isEmpty &&
        to_message.docs.isEmpty &&
        modeleImg.isNotEmpty) {
      var msg_data = MessageModel(
        from_avatar: user!.photoURL ?? '',
        from_name: user!.displayName,
        from_id: user!.uid,
        to_avatar: to_user.profileImage,
        to_name: to_user.nomPrenom,
        to_id: to_user.id,
        modele_img: modeleImg,
        message: '',
        last_msg: '',
        last_time: Timestamp.now(),
        msg_num: 0,
      );
      collection
          .withConverter(
              fromFirestore: MessageModel.fromMap,
              toFirestore: (MessageModel msg, options) => msg.toMap())
          .add(msg_data)
          .then((value) => {
                Get.to(() => const DiscussionView(),
                    transition: Transition.rightToLeftWithFade,
                    arguments: {
                      'doc_id': value.id,
                      'to_id': to_user.id,
                      'to_name': to_user.nomPrenom,
                      'to_avatar': to_user.profileImage,
                      'modele_img': modeleImg,
                      'token': to_user.token,
                    })
              });
    } else {
      if (from_message.docs.isNotEmpty) {
        Get.to(() => const DiscussionView(),
            transition: Transition.rightToLeftWithFade,
            arguments: {
              'doc_id': from_message.docs.first.id,
              'to_id': to_user.id,
              'to_name': to_user.nomPrenom,
              'to_avatar': to_user.profileImage,
              'modele_img': modeleImg,
              'token': to_user.token,
            });
      }
      if (to_message.docs.isNotEmpty) {
        Get.to(() => const DiscussionView(),
            transition: Transition.rightToLeftWithFade,
            arguments: {
              'doc_id': to_message.docs.first.id,
              'to_id': to_user.id,
              'to_name': to_user.nomPrenom,
              'to_avatar': to_user.profileImage,
              'modele_img': modeleImg,
              'token': to_user.token,
            });
      }
    }
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

  void increment() => count.value++;
}
