import 'package:cloud_firestore/cloud_firestore.dart';

class TailorClient {
  final String id;
  final String tailorId;
  final String name;
  final String phoneNumber;
  final String notes;
  final String garmentImageUrl;
  final String garmentImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  TailorClient({
    required this.id,
    required this.tailorId,
    required this.name,
    this.phoneNumber = '',
    this.notes = '',
    this.garmentImageUrl = '',
    this.garmentImagePath = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory TailorClient.fromMap(
    Map<String, dynamic> map,
    DocumentReference reference,
  ) {
    final createdAtRaw = map['createdAt'];
    final updatedAtRaw = map['updatedAt'];
    return TailorClient(
      id: reference.id,
      tailorId: (map['tailorId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      phoneNumber: (map['phoneNumber'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
      garmentImageUrl: (map['garmentImageUrl'] ?? '').toString(),
      garmentImagePath: (map['garmentImagePath'] ?? '').toString(),
      createdAt:
          createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now(),
      updatedAt:
          updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tailorId': tailorId,
      'name': name,
      'phoneNumber': phoneNumber,
      'notes': notes,
      'garmentImageUrl': garmentImageUrl,
      'garmentImagePath': garmentImagePath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TailorClient copyWith({
    String? id,
    String? tailorId,
    String? name,
    String? phoneNumber,
    String? notes,
    String? garmentImageUrl,
    String? garmentImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TailorClient(
      id: id ?? this.id,
      tailorId: tailorId ?? this.tailorId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
      garmentImageUrl: garmentImageUrl ?? this.garmentImageUrl,
      garmentImagePath: garmentImagePath ?? this.garmentImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
