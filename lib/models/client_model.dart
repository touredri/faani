import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;
class Client {
  String id;
  String nomPrenom;
  int telephone;
  String genre;
  String? quartier;

  Client(
      {required this.id,
      required this.nomPrenom,
      required this.telephone,
      required this.genre,
      this.quartier});

  // factory constructor fromMap
  factory Client.fromMap(Map<String, dynamic> map, DocumentReference docRef) {
    return Client(
      id: docRef.id,
      nomPrenom: map['nomPrenom'] as String,
      telephone: map['telephone'] as int,
      genre: map['genre'] as String,
      quartier: map['quartier'] as String?,
    );
  }

  // method toMap
  Map<String, dynamic> toMap() {
    return {
      'nomPrenom': nomPrenom,
      'telephone': telephone,
      'genre': genre,
      'quartier': quartier?? '',
    };
  }
}
