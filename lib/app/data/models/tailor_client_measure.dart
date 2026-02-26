import 'package:cloud_firestore/cloud_firestore.dart';

class TailorClientMeasure {
  final String id;
  final String tailorId;
  final String clientId;
  final String label;
  final String garmentType;
  final int epaule;
  final int bras;
  final int poignet;
  final int poitrine;
  final int taille;
  final int hanche;
  final int ventre;
  final int longueur;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TailorClientMeasure({
    required this.id,
    required this.tailorId,
    required this.clientId,
    required this.label,
    this.garmentType = 'Personnalisé',
    required this.epaule,
    required this.bras,
    required this.poignet,
    required this.poitrine,
    required this.taille,
    required this.hanche,
    required this.ventre,
    required this.longueur,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory TailorClientMeasure.fromMap(
    Map<String, dynamic> map,
    DocumentReference reference,
  ) {
    final createdAtRaw = map['createdAt'];
    final updatedAtRaw = map['updatedAt'];

    int asInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return TailorClientMeasure(
      id: reference.id,
      tailorId: (map['tailorId'] ?? '').toString(),
      clientId: (map['clientId'] ?? '').toString(),
      label: (map['label'] ?? '').toString(),
      garmentType: (map['garmentType'] ?? 'Personnalisé').toString(),
      epaule: asInt(map['epaule']),
      bras: asInt(map['bras']),
      poignet: asInt(map['poignet']),
      poitrine: asInt(map['poitrine']),
      taille: asInt(map['taille']),
      hanche: asInt(map['hanche']),
      ventre: asInt(map['ventre']),
      longueur: asInt(map['longueur']),
      notes: (map['notes'] ?? '').toString(),
      createdAt:
          createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now(),
      updatedAt:
          updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tailorId': tailorId,
      'clientId': clientId,
      'label': label,
      'garmentType': garmentType,
      'epaule': epaule,
      'bras': bras,
      'poignet': poignet,
      'poitrine': poitrine,
      'taille': taille,
      'hanche': hanche,
      'ventre': ventre,
      'longueur': longueur,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TailorClientMeasure copyWith({
    String? id,
    String? tailorId,
    String? clientId,
    String? label,
    String? garmentType,
    int? epaule,
    int? bras,
    int? poignet,
    int? poitrine,
    int? taille,
    int? hanche,
    int? ventre,
    int? longueur,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TailorClientMeasure(
      id: id ?? this.id,
      tailorId: tailorId ?? this.tailorId,
      clientId: clientId ?? this.clientId,
      label: label ?? this.label,
      garmentType: garmentType ?? this.garmentType,
      epaule: epaule ?? this.epaule,
      bras: bras ?? this.bras,
      poignet: poignet ?? this.poignet,
      poitrine: poitrine ?? this.poitrine,
      taille: taille ?? this.taille,
      hanche: hanche ?? this.hanche,
      ventre: ventre ?? this.ventre,
      longueur: longueur ?? this.longueur,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
