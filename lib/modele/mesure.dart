import 'package:cloud_firestore/cloud_firestore.dart';

class Measure {
  int? bras;
  int? epaule;
  int? hanche;
  String? idUser;
  int? longueur;
  int? poitrine;
  String? nom;
  String? id;
  int? taille;
  int? ventre;
  int? poignet;

  Measure({
    required this.bras,
    required this.epaule,
    required this.hanche,
    required this.idUser,
    required this.longueur,
    required this.poitrine,
    required this.nom,
    required this.id,
    required this.taille,
    required this.ventre,
    required this.poignet,
  });

  Map<String, dynamic> toMap() {
    return {
      'bras': bras,
      'epaule': epaule,
      'hanche': hanche,
      'idUser': idUser,
      'longueur': longueur,
      'poitrine': poitrine,
      'nom': nom,
    };
  }

  factory Measure.fromMap(
      Map<String, dynamic> map, DocumentReference reference) {
    return Measure(
      bras: map['bras'],
      epaule: map['epaule'],
      hanche: map['hanche'],
      idUser: map['idUser'],
      longueur: map['longueur'],
      poitrine: map['poitrine'],
      nom: map['nom'],
      id: reference.id,
      taille: map['taille'],
      ventre: map['ventre'],
      poignet: map['poignet'],
    );
  }

  final firestore = FirebaseFirestore.instance;

  Future<void> create() async {
    final collection = firestore.collection('mesure');
    final docRef = await collection.add(toMap());
    id = docRef.id;
  }
}
