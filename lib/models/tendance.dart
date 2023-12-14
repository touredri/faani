import 'package:cloud_firestore/cloud_firestore.dart';

class Tendance {
  String? id;
  String image;
  String categorie;
  String? details;

  Tendance({
    required this.id,
    required this.image,
    required this.categorie,
    this.details,
  });

  // from map
  factory Tendance.fromMap(Map<String, dynamic> map, DocumentReference docRef) {
    return Tendance(
      id: docRef.id,
      image: map['image'] as String,
      categorie: map['categorie'] as String,
      details: map['details'] as String?,
    );
  }  
}