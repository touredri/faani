import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/user_role.dart';
import 'package:faani/app/domain/profile/tailor_availability.dart';

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
      phoneE164,
      adress,
      profileImage,
      activeDeviceId,
      activeDeviceLabel,
      token,
      sex;
  String tailorBio;
  List<String> tailorSpecialties;
  TailorAvailability tailorAvailability;
  List<String> authProviders;
  Map<String, bool> notificationPreferences;
  AppUserRole role;
  bool isTailleur;
  DateTime? createdAt, updatedAt, lastLoginAt, identityBoundAt;
  List<String> followers;
  List<String> following;

  UserModel(
      {this.id,
      required this.nomPrenom,
      this.clientCible = '',
      this.email = '',
      required this.phoneNumber,
      this.phoneE164 = '',
      this.adress = '',
      this.profileImage,
      this.activeDeviceId,
      this.activeDeviceLabel,
      this.isTailleur = false,
      this.sex = '',
      this.token,
      this.tailorBio = '',
      this.tailorSpecialties = const [],
      this.tailorAvailability = TailorAvailability.available,
      this.role = AppUserRole.client,
      this.authProviders = const [],
      this.notificationPreferences = const {},
      this.followers = const [],
      this.following = const [],
      this.lastLoginAt,
      this.identityBoundAt,
      this.createdAt,
      this.updatedAt});

  factory UserModel.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    final id = documentReference.id;
    final nomPrenom = data['nomPrenom'];
    final clientCible = data['clientCible'];
    final email = data['email'];
    final phoneNumber = data['phoneNumber'];
    final phoneE164 = data['phoneE164'];
    final adress = data['adress'];
    final profileImage = data['profileImage'];
    final activeDeviceId = data['activeDeviceId'];
    final activeDeviceLabel = data['activeDeviceLabel'];
    final isTailleur = data['isTailleur'];
    final roleRaw = data['role']?.toString();
    final sex = data['sex'];
    final token = data['token'];
    final tailorBio = data['tailorBio']?.toString() ?? '';
    final tailorSpecialties =
        List<String>.from(data['tailorSpecialties'] ?? const []);
    final tailorAvailability = TailorAvailabilityValue.fromStorage(
        data['tailorAvailability']?.toString());
    final authProviders = List<String>.from(data['authProviders'] ?? []);
    final notificationPreferences = Map<String, bool>.from(
      (data['notificationPreferences'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value == true),
          ) ??
          const <String, bool>{},
    );
    final followers = List<String>.from(data['followers'] ?? []);
    final following = List<String>.from(data['following'] ?? []);
    final createdAtTs = data['createdAt'];
    final updatedAtTs = data['updatedAt'];
    final lastLoginAtTs = data['lastLoginAt'];
    final identityBoundAtTs = data['identityBoundAt'];
    final createdAt =
        createdAtTs is Timestamp ? createdAtTs.toDate() : DateTime.now();
    final updatedAt =
        updatedAtTs is Timestamp ? updatedAtTs.toDate() : DateTime.now();
    final lastLoginAt =
        lastLoginAtTs is Timestamp ? lastLoginAtTs.toDate() : null;
    final identityBoundAt =
        identityBoundAtTs is Timestamp ? identityBoundAtTs.toDate() : null;

    return UserModel(
      id: id,
      nomPrenom: nomPrenom,
      clientCible: clientCible,
      email: email,
      phoneNumber: phoneNumber,
      phoneE164: phoneE164,
      adress: adress,
      profileImage: profileImage,
      activeDeviceId: activeDeviceId,
      activeDeviceLabel: activeDeviceLabel,
      isTailleur: isTailleur,
      role: (roleRaw ?? '').trim().isNotEmpty
          ? appUserRoleFromString(roleRaw)
          : (isTailleur == true ? AppUserRole.tailor : AppUserRole.client),
      sex: sex,
      token: token,
      tailorBio: tailorBio,
      tailorSpecialties: tailorSpecialties,
      tailorAvailability: tailorAvailability,
      authProviders: authProviders,
      notificationPreferences: notificationPreferences,
      followers: followers,
      following: following,
      lastLoginAt: lastLoginAt,
      identityBoundAt: identityBoundAt,
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
      'phoneE164': phoneE164,
      'adress': adress,
      'profileImage': profileImage,
      'activeDeviceId': activeDeviceId,
      'activeDeviceLabel': activeDeviceLabel,
      'isTailleur': isTailleur,
      'role': appUserRoleToString(role),
      'sex': sex,
      'token': token,
      'tailorBio': tailorBio,
      'tailorSpecialties': tailorSpecialties,
      'tailorAvailability': tailorAvailability.storageValue,
      'authProviders': authProviders,
      'notificationPreferences': notificationPreferences,
      'followers': followers,
      'following': following,
      'lastLoginAt': lastLoginAt,
      'identityBoundAt': identityBoundAt,
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
    String? phoneE164,
    String? adress,
    String? profileImage,
    String? activeDeviceId,
    String? activeDeviceLabel,
    bool? isTailleur,
    AppUserRole? role,
    List<String>? authProviders,
    Map<String, bool>? notificationPreferences,
    List<String>? followers,
    List<String>? following,
    String? sex,
    String? token,
    String? tailorBio,
    List<String>? tailorSpecialties,
    TailorAvailability? tailorAvailability,
    DateTime? lastLoginAt,
    DateTime? identityBoundAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nomPrenom: nomPrenom ?? this.nomPrenom,
      clientCible: clientCible ?? this.clientCible,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneE164: phoneE164 ?? this.phoneE164,
      adress: adress ?? this.adress,
      profileImage: profileImage ?? this.profileImage,
      activeDeviceId: activeDeviceId ?? this.activeDeviceId,
      activeDeviceLabel: activeDeviceLabel ?? this.activeDeviceLabel,
      isTailleur: isTailleur ?? this.isTailleur,
      role: role ?? this.role,
      authProviders: authProviders ?? this.authProviders,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      sex: sex ?? this.sex,
      token: token ?? this.token,
      tailorBio: tailorBio ?? this.tailorBio,
      tailorSpecialties: tailorSpecialties ?? this.tailorSpecialties,
      tailorAvailability: tailorAvailability ?? this.tailorAvailability,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      identityBoundAt: identityBoundAt ?? this.identityBoundAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
