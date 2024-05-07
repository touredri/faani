import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/firebase/global_function.dart';

class Commande {
  String? id;
  String idUser,
      idMesure,
      idModele,
      idTailleur,
      nomClient,
      photoHabit,
      refPhotoHabit,
      idCategorie,
      etatLibelle,
      modeleImage;
      final DateTime dateAjout;
  DateTime datePrevue, dateModifier;
  int? numeroClient;
  int prix;
  bool isSelfAdded, isAccepted;

  Commande({
    required this.id,
    DateTime? dateAjout,
    required this.datePrevue,
    required this.dateModifier,
    this.idUser = '',
    required this.idMesure,
    required this.idModele,
    required this.idTailleur,
    required this.numeroClient,
    this.nomClient = '',
    this.photoHabit = '',
    this.refPhotoHabit = '',
    required this.prix,
    required this.idCategorie,
    this.isSelfAdded = false,
    this.isAccepted = false,
    this.etatLibelle = 'En cours',
    required this.modeleImage,
  }) : dateAjout = dateAjout ?? DateTime.now();

  factory Commande.fromMap(
      Map<String, dynamic> data, DocumentReference docRef) {
    return Commande(
      id: docRef.id,
      dateAjout: (data['dateAjout'] as Timestamp).toDate(),
      datePrevue: (data['datePrevue'] as Timestamp).toDate(),
      dateModifier: (data['dateModifier'] as Timestamp).toDate(),
      idUser: data['idUser'],
      idMesure: data['idMesure'],
      idModele: data['idModele'],
      idTailleur: data['idTailleur'],
      numeroClient: data['numeroClient'],
      nomClient: data['nomClient'],
      photoHabit: data['photoHabit'],
      refPhotoHabit: data['refPhotoHabit'],
      prix: data['prix'],
      idCategorie: data['idCategorie'],
      isSelfAdded: data['isSelfAdded'],
      isAccepted: data['isAccepted'],
      modeleImage: data['modeleImage'] ?? '',
      etatLibelle: data['etatLibele'] ?? 'En cours',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateAjout': dateAjout,
      'datePrevue': datePrevue,
      'dateModifier': dateModifier,
      'idUser': idUser,
      'idMesure': idMesure,
      'idModele': idModele,
      'idTailleur': idTailleur,
      'numeroClient': numeroClient,
      'nomClient': nomClient,
      'photoHabit': photoHabit,
      'refPhotoHabit': refPhotoHabit,
      'prix': prix,
      'idCategorie': idCategorie,
      'isSelfAdded': isSelfAdded,
      'isAccepted': isAccepted,
      'modeleImage': modeleImage,
      'etatLibele': etatLibelle,
    };
  }

  final collection = FirebaseFirestore.instance.collection('commandes');

  // create
  Future<void> create() async {
    final docRef = await collection.add(toMap());
    id = docRef.id;
  }

  // update
  Future<void> update() async {
    await collection.doc(id).update(toMap());
  }

  // delete
  Future<void> delete() async {
    await collection.doc(id).delete();
    // delete image if exist is firebase storage
    if (photoHabit.isNotEmpty) {
      await deleteImage(photoHabit);
    }
  }

  Future<bool> isAlreadyOrdered(String clientId, String modelId) async {
    final snapshot = await collection
        .where('idUser', isEqualTo: clientId)
        .where('idModele', isEqualTo: modelId)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
