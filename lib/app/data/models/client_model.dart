import 'package:cloud_firestore/cloud_firestore.dart';

final collection = FirebaseFirestore.instance.collection('client');
class Client {
  String id;
  String nomPrenom;
  int telephone;
  String genre;
  String? quartier;
  String profile;

  Client(
      {required this.id,
      required this.nomPrenom,
      required this.telephone,
      required this.genre,
      this.quartier,
      this.profile = ""});

  // factory constructor fromMap
  factory Client.fromMap(Map<String, dynamic> map, DocumentReference docRef) {
    return Client(
      id: docRef.id,
      nomPrenom: map['nomPrenom'] as String,
      telephone: map['telephone'] as int,
      genre: map['genre'] as String,
      quartier: map['quartier'] as String?,
      profile: map['profile'] as String,
    );
  }

  // method toMap
  Map<String, dynamic> toMap() {
    return {
      'nomPrenom': nomPrenom,
      'telephone': telephone,
      'genre': genre,
      'quartier': quartier?? '',
      'profile': profile,
    };
  }

    // method create
  Future<void> create() async {
    // final collection = firestore.collection('client');
    await collection.doc(id).set(toMap());
  }

  // method delete
  Future<void> delete() async {
    final documentReference = collection.doc();
    await documentReference.delete();
  }

  // method update
  Future<void> update() async {
    final documentReference = collection.doc();
    await documentReference.update(toMap());
  }
}
