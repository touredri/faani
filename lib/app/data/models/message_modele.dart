import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? from_avatar,
      from_name,
      from_id,
      to_avatar,
      to_name,
      to_id,
      message,
      modele_img,
      last_msg;
  int? msg_num;
  Timestamp? last_time;

  MessageModel({
    this.from_avatar,
    this.from_name,
    this.from_id,
    this.to_avatar,
    this.to_name,
    this.to_id,
    this.message,
    this.modele_img,
    this.last_msg,
    this.msg_num = 0,
    this.last_time,
  });

  factory MessageModel.fromMap(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MessageModel(
      from_avatar: data?['from_avatar'],
      from_name: data?['from_name'],
      from_id: data?['from_id'],
      to_avatar: data?['to_avatar'],
      to_name: data?['to_name'],
      to_id: data?['to_id'],
      modele_img: data?['modele_img'],
      message: data?['message'],
      last_msg: data?['last_msg'],
      msg_num: data?['msg_num'],
      last_time: data?['last_time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (from_avatar != null) 'from_avatar': from_avatar,
      if (from_name != null) 'from_name': from_name,
      if (from_id != null) 'from_id': from_id,
      if (to_avatar != null) 'to_avatar': to_avatar,
      if (to_name != null) 'to_name': to_name,
      if (to_id != null) 'to_id': to_id,
      if (message != null) 'message': message,
      if (modele_img != null) 'modele_img': modele_img,
      if (last_msg != null) 'last_msg': last_msg,
      if (msg_num != null) 'msg_num': msg_num,
      if (last_time != null) 'last_time': last_time,
    };
  }
}

class MsgContent {
  final String? id, content, type;
  final Timestamp? addtime;

  MsgContent({ this.id, this.content, this.type, this.addtime});

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
