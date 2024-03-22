import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id,
      nomPrenom,
      clientCible,
      email,
      phoneNumber,
      adress,
      profileImage,
      sex;
  bool  isTailleur ;
  DateTime? createdAt, updatedAt;

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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    });
  }
}
