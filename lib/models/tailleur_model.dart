import 'package:cloud_firestore/cloud_firestore.dart';


final firestore = FirebaseFirestore.instance;

class Tailleur {
  String id;
  String quartier;
  String genreHabit;
  bool isVerify;
  String nomPrenom;
  int telephone;
  String genre;

  Tailleur(
      {required this.quartier,
      required this.genreHabit,
      required this.isVerify,
      required this.nomPrenom,
      required this.telephone,
      required this.genre,
      required this.id});

  // factory constructor fromMap
  factory Tailleur.fromMap(Map<String, dynamic> map, DocumentReference docRef) {
    return Tailleur(
      quartier: map['quartier'] as String,
      genreHabit: map['genreHabit'] as String,
      isVerify: map['isVerify'] as bool,
      nomPrenom: map['nomPrenom'] as String,
      telephone: map['telephone'] as int,
      genre: map['genre'] as String,
      id: docRef.id,
    );
  }

  // method toMap
  Map<String, dynamic> toMap() {
    return {
      'quartier': quartier,
      'genreHabit': genreHabit,
      'isVerify': isVerify,
      'nomPrenom': nomPrenom,
      'telephone': telephone,
      'genre': genre,
    };
  }
}
