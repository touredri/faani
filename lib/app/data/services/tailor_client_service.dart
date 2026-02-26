import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/tailor_client.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class TailorClientService {
  final CollectionReference _clientsRef =
      FirebaseFirestore.instance.collection('tailorClients');

  Stream<List<TailorClient>> getClientsByTailor(String tailorId) {
    return _clientsRef
        .where('tailorId', isEqualTo: tailorId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((doc) => TailorClient.fromMap(
                doc.data() as Map<String, dynamic>, doc.reference))
            .toList());
  }

  Future<String> createClient(TailorClient client) async {
    final docRef = await _clientsRef.add(client.toMap());
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  Future<void> updateClient(TailorClient client) {
    return _clientsRef.doc(client.id).update(client.toMap());
  }

  Future<void> deleteClient(TailorClient client) async {
    await _deleteImageByPath(client.garmentImagePath);
    await _clientsRef.doc(client.id).delete();
  }

  Future<Map<String, String>> uploadGarmentImage({
    required XFile image,
    required String tailorId,
    required String clientId,
  }) async {
    final file = File(image.path);
    final ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child('garments')
        .child(tailorId)
        .child(clientId)
        .child(file.path.split('/').last);
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();
    return {
      'downloadUrl': downloadUrl,
      'path': ref.fullPath,
    };
  }

  Future<Map<String, String>> replaceGarmentImage({
    required TailorClient client,
    required XFile image,
  }) async {
    final upload = await uploadGarmentImage(
      image: image,
      tailorId: client.tailorId,
      clientId: client.id,
    );

    if (client.garmentImagePath.trim().isNotEmpty &&
        client.garmentImagePath.trim() != (upload['path'] ?? '').trim()) {
      await _deleteImageByPath(client.garmentImagePath);
    }

    return upload;
  }

  Future<void> _deleteImageByPath(String path) async {
    if (path.trim().isEmpty) return;
    try {
      await FirebaseStorage.instance.ref(path).delete();
    } catch (_) {}
  }
}
