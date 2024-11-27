import 'package:cloud_firestore/cloud_firestore.dart';

class Follower {
  String idUser;
  Follower({required this.idUser});
}

class UserModel {
  String? id,
      nomPrenom,
      clientCible,
      email,
      phoneNumber,
      adress,
      profileImage,
      token,
      sex;
  bool isTailleur;
  DateTime? createdAt, updatedAt;
  List<String> followers;
  List<String> following;

  UserModel(
      {this.id,
      required this.nomPrenom,
      this.clientCible = '',
      this.email = '',
      required this.phoneNumber,
      this.adress = '',
      this.profileImage,
      this.isTailleur = false,
      this.sex = '',
      this.token,
      this.followers = const [],
      this.following = const [],
      this.createdAt,
      this.updatedAt});

  factory UserModel.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    final id = documentReference.id;
    final nomPrenom = data['nomPrenom'];
    final clientCible = data['clientCible'];
    final email = data['email'];
    final phoneNumber = data['phoneNumber'];
    final adress = data['adress'];
    final profileImage = data['profileImage'];
    final isTailleur = data['isTailleur'];
    final sex = data['sex'];
    final token = data['token'];
    final followers = List<String>.from(data['followers'] ?? []);
    final following = List<String>.from(data['following'] ?? []);
    final createdAt = (data['createdAt'] as Timestamp).toDate();
    final updatedAt = (data['updatedAt'] as Timestamp).toDate();

    return UserModel(
      id: id,
      nomPrenom: nomPrenom,
      clientCible: clientCible,
      email: email,
      phoneNumber: phoneNumber,
      adress: adress,
      profileImage: profileImage,
      isTailleur: isTailleur,
      sex: sex,
      token: token,
      followers: followers,
      following: following,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return ({
      'nomPrenom': nomPrenom,
      'clientCible': clientCible,
      'email': email,
      'phoneNumber': phoneNumber,
      'adress': adress,
      'profileImage': profileImage,
      'isTailleur': isTailleur,
      'sex': sex,
      'token': token,
      'followers': followers,
      'following': following,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    });
  }

  UserModel copyWith({
    String? id,
    String? nomPrenom,
    String? clientCible,
    String? email,
    String? phoneNumber,
    String? adress,
    String? profileImage,
    bool? isTailleur,
    String? sex,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nomPrenom: nomPrenom ?? this.nomPrenom,
      clientCible: clientCible ?? this.clientCible,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      adress: adress ?? this.adress,
      profileImage: profileImage ?? this.profileImage,
      isTailleur: isTailleur ?? this.isTailleur,
      sex: sex ?? this.sex,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
