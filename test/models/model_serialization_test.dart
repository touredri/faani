import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/user_role.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel serialization', () {
    test('toMap preserves the persisted user contract', () {
      final createdAt = DateTime.utc(2025, 1, 2);
      final updatedAt = DateTime.utc(2025, 2, 3);
      final lastLoginAt = DateTime.utc(2025, 3, 4);
      final identityBoundAt = DateTime.utc(2025, 4, 5);
      final user = UserModel(
        id: 'user-1',
        nomPrenom: 'Awa Traoré',
        clientCible: 'Femmes',
        email: 'awa@example.com',
        phoneNumber: '70000000',
        phoneE164: '+22370000000',
        adress: 'Bamako',
        profileImage: 'profile.jpg',
        activeDeviceId: 'device-1',
        activeDeviceLabel: 'Android',
        isTailleur: true,
        role: AppUserRole.tailor,
        authProviders: const ['phone', 'google'],
        followers: const ['follower-1'],
        following: const ['following-1'],
        sex: 'F',
        token: 'token-1',
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastLoginAt: lastLoginAt,
        identityBoundAt: identityBoundAt,
      );

      expect(user.toMap(), {
        'nomPrenom': 'Awa Traoré',
        'clientCible': 'Femmes',
        'email': 'awa@example.com',
        'phoneNumber': '70000000',
        'phoneE164': '+22370000000',
        'adress': 'Bamako',
        'profileImage': 'profile.jpg',
        'activeDeviceId': 'device-1',
        'activeDeviceLabel': 'Android',
        'isTailleur': true,
        'role': 'tailor',
        'sex': 'F',
        'token': 'token-1',
        'authProviders': ['phone', 'google'],
        'followers': ['follower-1'],
        'following': ['following-1'],
        'lastLoginAt': lastLoginAt,
        'identityBoundAt': identityBoundAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      });
    });

    test('copyWith retains relationship lists unless explicitly replaced', () {
      final user = UserModel(
        id: 'user-1',
        nomPrenom: 'Awa',
        phoneNumber: '70000000',
        followers: const ['follower-1'],
        following: const ['following-1'],
      );

      final renamed = user.copyWith(nomPrenom: 'Awa Traoré');
      final replaced = user.copyWith(
        followers: const ['follower-2'],
        following: const ['following-2'],
      );

      expect(renamed.followers, ['follower-1']);
      expect(renamed.following, ['following-1']);
      expect(replaced.followers, ['follower-2']);
      expect(replaced.following, ['following-2']);
    });
  });

  test('Modele.toMap preserves ranking and visibility fields', () {
    final createdAt = Timestamp.fromDate(DateTime.utc(2025, 5, 6));
    final modele = Modele(
      id: 'modele-1',
      detail: 'Boubou brodé',
      fichier: const ['image.jpg'],
      imagePath: const ['images/image.jpg'],
      createdAt: createdAt,
      likeCount: 12,
      viewCount: 34,
      genreHabit: 'Femme',
      idTailleur: 'tailleur-1',
      idCategorie: 'categorie-1',
      isPublic: true,
      isApproved: true,
    );

    expect(modele.toMap(), {
      'detail': 'Boubou brodé',
      'fichier': ['image.jpg'],
      'imagePath': ['images/image.jpg'],
      'createdAt': createdAt,
      'likeCount': 12,
      'viewCount': 34,
      'genreHabit': 'Femme',
      'idTailleur': 'tailleur-1',
      'idCategorie': 'categorie-1',
      'isPublic': true,
      'isApproved': true,
    });
  });

  test('Commande.toMap preserves dates, workflow and legacy field names', () {
    final dateAjout = DateTime.utc(2025, 6, 1);
    final datePrevue = DateTime.utc(2025, 6, 15);
    final dateModifier = DateTime.utc(2025, 6, 2);
    final commande = Commande(
      id: 'commande-1',
      dateAjout: dateAjout,
      datePrevue: datePrevue,
      dateModifier: dateModifier,
      idUser: 'client-1',
      idMesure: 'mesure-1',
      idModele: 'modele-1',
      idTailleur: 'tailleur-1',
      numeroClient: 70000000,
      nomClient: 'Awa Traoré',
      photoHabit: 'photo.jpg',
      refPhotoHabit: 'images/photo.jpg',
      prix: 25000,
      idCategorie: 'categorie-1',
      isSelfAdded: false,
      isAccepted: true,
      etatLibelle: 'Acceptée',
      modeleImage: 'modele.jpg',
    );

    expect(commande.toMap(), {
      'dateAjout': dateAjout,
      'datePrevue': datePrevue,
      'dateModifier': dateModifier,
      'idUser': 'client-1',
      'idMesure': 'mesure-1',
      'idModele': 'modele-1',
      'idTailleur': 'tailleur-1',
      'numeroClient': 70000000,
      'nomClient': 'Awa Traoré',
      'photoHabit': 'photo.jpg',
      'refPhotoHabit': 'images/photo.jpg',
      'prix': 25000,
      'idCategorie': 'categorie-1',
      'isSelfAdded': false,
      'isAccepted': true,
      'modeleImage': 'modele.jpg',
      'etatLibele': 'Acceptée',
    });
  });
}
