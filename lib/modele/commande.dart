import 'package:cloud_firestore/cloud_firestore.dart';

class Commande {
  String id;
  DateTime dateCommande;
  DateTime dateRecuperation;
  String idClient;
  String idMesure;
  String idModele;
  String idTailleur;
  int prix;

  Commande({
    required this.id,
    required this.dateCommande,
    required this.dateRecuperation,
    required this.idClient,
    required this.idMesure,
    required this.idModele,
    required this.idTailleur,
    required this.prix,
  });

  factory Commande.fromMap(Map<String, dynamic> data, String id) {
    return Commande(
      id: id,
      dateCommande: (data['dateCommande'] as Timestamp).toDate(),
      dateRecuperation: (data['dateRecuperation'] as Timestamp).toDate(),
      idClient: data['idClient'],
      idMesure: data['idMesure'],
      idModele: data['idModele'],
      idTailleur: data['idTailleur'],
      prix: data['prix'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateCommande': dateCommande,
      'dateRecuperation': dateRecuperation,
      'idClient': idClient,
      'idMesure': idMesure,
      'idModele': idModele,
      'idTailleur': idTailleur,
      'prix': prix,
    };
  }
}

class CommandeAnonyme {
  String? id;
  DateTime? dateCommande;
  DateTime? dateRecuperation;
  String? idModele;
  String idTailleur;
  int? prix;
  int? numeroClient;
  String? nomClient;
  String? image;
  String? idMesure;
  String? idCategorie;

  CommandeAnonyme({
    required this.id,
    required this.dateCommande,
    required this.dateRecuperation,
    required this.idModele,
    required this.idTailleur,
    required this.prix,
    required this.numeroClient,
    required this.nomClient,
    required this.image,
    required this.idMesure,
    required this.idCategorie,
  });

  factory CommandeAnonyme.fromMap(
      Map<String, dynamic> data, DocumentReference docRef) {
    return CommandeAnonyme(
      id: docRef.id,
      dateCommande: (data['dateCommande'] as Timestamp).toDate(),
      dateRecuperation: (data['dateRecuperation'] as Timestamp).toDate(),
      idModele: data['idModele'],
      idTailleur: data['idTailleur'],
      prix: data['prix'],
      numeroClient: data['numeroClient'],
      nomClient: data['nomClient'],
      image: data['image'],
      idMesure: data['idMesure'],
      idCategorie: data['idCategorie'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateCommande': dateCommande,
      'dateRecuperation': dateRecuperation,
      'idModele': idModele,
      'idTailleur': idTailleur,
      'prix': prix,
      'numeroClient': numeroClient,
      'nomClient': nomClient,
      'image': image,
      'idMesure': idMesure,
      'idCategorie': idCategorie,
    };
  }

  Future<void> create() async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('commandeAnomyme');
    final docRef = await collection.add(toMap());
    id = docRef.id;
  }
}
