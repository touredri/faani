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
      activeDeviceId,
      activeDeviceLabel,
      token,
      sex;
  bool isTailleur;
  DateTime? createdAt, updatedAt, lastLoginAt;
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
      this.activeDeviceId,
      this.activeDeviceLabel,
      this.isTailleur = false,
      this.sex = '',
      this.token,
      this.followers = const [],
      this.following = const [],
      this.lastLoginAt,
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
    final activeDeviceId = data['activeDeviceId'];
    final activeDeviceLabel = data['activeDeviceLabel'];
    final isTailleur = data['isTailleur'];
    final sex = data['sex'];
    final token = data['token'];
    final followers = List<String>.from(data['followers'] ?? []);
    final following = List<String>.from(data['following'] ?? []);
    final createdAtTs = data['createdAt'];
    final updatedAtTs = data['updatedAt'];
    final lastLoginAtTs = data['lastLoginAt'];
    final createdAt =
        createdAtTs is Timestamp ? createdAtTs.toDate() : DateTime.now();
    final updatedAt =
        updatedAtTs is Timestamp ? updatedAtTs.toDate() : DateTime.now();
    final lastLoginAt =
        lastLoginAtTs is Timestamp ? lastLoginAtTs.toDate() : null;

    return UserModel(
      id: id,
      nomPrenom: nomPrenom,
      clientCible: clientCible,
      email: email,
      phoneNumber: phoneNumber,
      adress: adress,
      profileImage: profileImage,
      activeDeviceId: activeDeviceId,
      activeDeviceLabel: activeDeviceLabel,
      isTailleur: isTailleur,
      sex: sex,
      token: token,
      followers: followers,
      following: following,
      lastLoginAt: lastLoginAt,
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
      'activeDeviceId': activeDeviceId,
      'activeDeviceLabel': activeDeviceLabel,
      'isTailleur': isTailleur,
      'sex': sex,
      'token': token,
      'followers': followers,
      'following': following,
      'lastLoginAt': lastLoginAt,
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
    String? activeDeviceId,
    String? activeDeviceLabel,
    bool? isTailleur,
    String? sex,
    String? token,
    DateTime? lastLoginAt,
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
      activeDeviceId: activeDeviceId ?? this.activeDeviceId,
      activeDeviceLabel: activeDeviceLabel ?? this.activeDeviceLabel,
      isTailleur: isTailleur ?? this.isTailleur,
      sex: sex ?? this.sex,
      token: token ?? this.token,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
