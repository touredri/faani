import 'package:cloud_firestore/cloud_firestore.dart';

class Mesure {
  int? bras, epaule, hanche, longueur, poitrine, taille, ventre, poignet;
  String? idUser, nom, id;
  DateTime? date, updateDate;

  Mesure({
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
    required this.date,
    this.updateDate,
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
      'taille': taille,
      'ventre': ventre,
      'poignet': poignet,
      'date': date,
      'updateDate': updateDate ?? Timestamp.now(),
    };
  }

  factory Mesure.fromMap(
      Map<String, dynamic> map, DocumentReference reference) {
    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.round();
      return int.tryParse(value?.toString() ?? '');
    }

    DateTime? asDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return Mesure(
      bras: asInt(map['bras']),
      epaule: asInt(map['epaule']),
      hanche: asInt(map['hanche']),
      idUser: map['idUser']?.toString(),
      longueur: asInt(map['longueur']),
      poitrine: asInt(map['poitrine']),
      nom: map['nom']?.toString(),
      id: reference.id,
      taille: asInt(map['taille']),
      ventre: asInt(map['ventre']),
      poignet: asInt(map['poignet']),
      date: asDate(map['date']),
      updateDate: asDate(map['updateDate']),
    );
  }

  final collection = FirebaseFirestore.instance.collection('mesure');

  Future<void> create() async {
    final docRef = await collection.add(toMap());
    await docRef.update({'id': docRef.id});
    id = docRef.id;
  }

  Future<void> update() async {
    await collection.doc(id).update(toMap());
  }

  Future<void> delete() async {
    await collection.doc(id).delete();
  }

  //change specific field
  Future<void> updateField(String field, dynamic value) async {
    await collection.doc(id).update({field: value});
  }

  // copyWith
  Mesure copyWith({
    int? bras,
    int? epaule,
    int? hanche,
    String? idUser,
    int? longueur,
    int? poitrine,
    String? nom,
    String? id,
    int? taille,
    int? ventre,
    int? poignet,
    DateTime? date,
  }) {
    return Mesure(
      bras: bras ?? this.bras,
      epaule: epaule ?? this.epaule,
      hanche: hanche ?? this.hanche,
      idUser: idUser ?? this.idUser,
      longueur: longueur ?? this.longueur,
      poitrine: poitrine ?? this.poitrine,
      nom: nom ?? this.nom,
      id: id ?? this.id,
      taille: taille ?? this.taille,
      ventre: ventre ?? this.ventre,
      poignet: poignet ?? this.poignet,
      date: date ?? this.date,
    );
  }
}

// // get mesure by id
// Stream<Mesure> getById(String id) {
//   return FirebaseFirestore.instance
//       .collection('mesure')
//       .doc(id)
//       .snapshots()
//       .map((snapshot) {
//     return Mesure.fromMap(snapshot.data()!, snapshot.reference);
//   });
// }
