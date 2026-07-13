import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/suivi_etat_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';
import 'package:faani/app/domain/order/create_order_use_case.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> accept(String orderId) {
    return _firestore.collection('commandes').doc(orderId).update({
      'isAccepted': true,
    });
  }

  @override
  Future<String> create(Commande commande, {required String requestId}) async {
    final reference = _firestore.collection('commandes').doc(requestId);
    await reference.set({...commande.toMap(), 'id': requestId});
    return requestId;
  }

  @override
  Future<void> delete(String orderId) {
    return _firestore.collection('commandes').doc(orderId).delete();
  }
}

class FirebaseOrderMediaService implements OrderMediaService {
  FirebaseOrderMediaService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<OrderMedia> upload(String filePath) async {
    final file = File(filePath);
    final reference = _storage
        .ref()
        .child('images')
        .child('habits')
        .child(file.path.split('/').last);
    await reference.putFile(file);
    return OrderMedia(
      downloadUrl: await reference.getDownloadURL(),
      storagePath: reference.fullPath,
    );
  }

  @override
  Future<void> delete(String storagePath) {
    return _storage.ref(storagePath).delete();
  }
}

class FirebaseOrderTrackingService implements OrderTrackingService {
  FirebaseOrderTrackingService(this._service);
  final SuiviEtatService _service;

  @override
  Future<void> createInitial(String orderId, DateTime createdAt) {
    return _service.createSuiviEtat(
      SuiviEtat(
        id: '',
        idCommande: orderId,
        idEtat: '1',
        date: Timestamp.fromDate(createdAt),
      ),
    );
  }

  @override
  Future<void> deleteForOrder(String orderId) {
    return _service.deleteSuiviEtat(orderId);
  }
}

class FirebaseOrderNotificationService implements OrderNotificationService {
  const FirebaseOrderNotificationService();

  @override
  Future<void> notifyCreated({
    required Commande commande,
    required UserModel tailor,
    required String clientName,
    required String clientToken,
  }) async {
    final token = tailor.token;
    if (token == null || token.isEmpty) return;
    await sendNotification(
      token,
      'Nouvelle commande',
      'Vous avez une nouvelle commande de $clientName',
    );
    await sendProgrammingNotification(
      token,
      clientToken,
      'Alert date Prevue',
      'La date prevue pour l\'habit de $clientName est arrivé',
      commande.datePrevue,
    );
  }
}
