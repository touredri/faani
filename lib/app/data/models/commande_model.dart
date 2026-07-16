import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/domain/order/order_stage.dart';

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
    DateTime asDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Commande(
      id: docRef.id,
      dateAjout: asDate(data['dateAjout']),
      datePrevue: asDate(data['datePrevue']),
      dateModifier: asDate(data['dateModifier']),
      idUser: (data['idUser'] ?? '').toString(),
      idMesure: (data['idMesure'] ?? '').toString(),
      idModele: (data['idModele'] ?? '').toString(),
      idTailleur: (data['idTailleur'] ?? '').toString(),
      numeroClient: data['numeroClient'],
      nomClient: data['nomClient'],
      photoHabit: data['photoHabit'],
      refPhotoHabit: data['refPhotoHabit'],
      prix: data['prix'],
      idCategorie: data['idCategorie'],
      isSelfAdded: data['isSelfAdded'],
      isAccepted: data['isAccepted'],
      modeleImage: data['modeleImage'] ?? '',
      etatLibelle:
          (data['etatLibelle'] ?? data['etatLibele'] ?? 'En cours').toString(),
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
      'etatLibelle': etatLibelle,
    };
  }

  OrderStage get stage =>
      OrderStageParsing.fromStoredValue(etatLibelle, isSelfAdded: isSelfAdded);

  CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('commandes');

  // create
  Future<String> create() async {
    final docRef = await collection.add(toMap());
    await docRef.update({'id': docRef.id});
    return docRef.id;
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
