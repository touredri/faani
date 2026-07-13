import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? fromAvatar,
      fromName,
      fromId,
      toAvatar,
      toName,
      toId,
      message,
      modeleImg,
      lastMsg;
  int? msgNum;
  Timestamp? lastTime;

  MessageModel({
    this.fromAvatar,
    this.fromName,
    this.fromId,
    this.toAvatar,
    this.toName,
    this.toId,
    this.message,
    this.modeleImg,
    this.lastMsg,
    this.msgNum = 0,
    this.lastTime,
  });

  factory MessageModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MessageModel(
      fromAvatar: data?['from_avatar'],
      fromName: data?['from_name'],
      fromId: data?['from_id'],
      toAvatar: data?['to_avatar'],
      toName: data?['to_name'],
      toId: data?['to_id'],
      modeleImg: data?['modele_img'],
      message: data?['message'],
      lastMsg: data?['last_msg'],
      msgNum: data?['msg_num'],
      lastTime: data?['last_time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (fromAvatar != null) 'from_avatar': fromAvatar,
      if (fromName != null) 'from_name': fromName,
      if (fromId != null) 'from_id': fromId,
      if (toAvatar != null) 'to_avatar': toAvatar,
      if (toName != null) 'to_name': toName,
      if (toId != null) 'to_id': toId,
      if (message != null) 'message': message,
      if (modeleImg != null) 'modele_img': modeleImg,
      if (lastMsg != null) 'last_msg': lastMsg,
      if (msgNum != null) 'msg_num': msgNum,
      if (lastTime != null) 'last_time': lastTime,
    };
  }
}

class MsgContent {
  final String? id, content, type;
  final Timestamp? addtime;

  MsgContent({this.id, this.content, this.type, this.addtime});

  factory MsgContent.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MsgContent(
      id: data?['id'],
      content: data?['content'],
      type: data?['type'],
      addtime: data?['addtime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (addtime != null) 'addtime': addtime,
    };
  }
}
