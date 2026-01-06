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

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    update(['search']);
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

  void goChat(UserModel toUser, {String modeleImg = ''}) async {
    var fromMessage = await collection
        .withConverter(
            fromFirestore: MessageModel.fromMap,
            toFirestore: (MessageModel msg, options) => msg.toMap())
        .where('from_id', isEqualTo: user!.uid)
        .where('to_id', isEqualTo: toUser.id)
        .get();

    var toMessage = await collection
        .withConverter(
            fromFirestore: MessageModel.fromMap,
            toFirestore: (MessageModel msg, options) => msg.toMap())
        .where('from_id', isEqualTo: toUser.id)
        .where('to_id', isEqualTo: user!.uid)
        .get();

    if (fromMessage.docs.isEmpty &&
        toMessage.docs.isEmpty &&
        modeleImg.isNotEmpty) {
      var msgData = MessageModel(
        from_avatar: user!.photoURL ?? '',
        from_name: user!.displayName,
        from_id: user!.uid,
        to_avatar: toUser.profileImage,
        to_name: toUser.nomPrenom,
        to_id: toUser.id,
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
          .add(msgData)
          .then((value) => {
                Get.to(() => const DiscussionView(),
                    transition: Transition.rightToLeftWithFade,
                    arguments: {
                      'doc_id': value.id,
                      'to_id': toUser.id,
                      'to_name': toUser.nomPrenom,
                      'to_avatar': toUser.profileImage,
                      'modele_img': modeleImg,
                      'token': toUser.token,
                    })
              });
    } else {
      if (fromMessage.docs.isNotEmpty) {
        Get.to(() => const DiscussionView(),
            transition: Transition.rightToLeftWithFade,
            arguments: {
              'doc_id': fromMessage.docs.first.id,
              'to_id': toUser.id,
              'to_name': toUser.nomPrenom,
              'to_avatar': toUser.profileImage,
              'modele_img': modeleImg,
              'token': toUser.token,
            });
      }
      if (toMessage.docs.isNotEmpty) {
        Get.to(() => const DiscussionView(),
            transition: Transition.rightToLeftWithFade,
            arguments: {
              'doc_id': toMessage.docs.first.id,
              'to_id': toUser.id,
              'to_name': toUser.nomPrenom,
              'to_avatar': toUser.profileImage,
              'modele_img': modeleImg,
              'token': toUser.token,
            });
      }
    }
  }




  void increment() => count.value++;
}
