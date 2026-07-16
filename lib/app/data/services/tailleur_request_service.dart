import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tailleur_request.dart';

class TailleurRequestService {
  final CollectionReference _tailleurRef =
      FirebaseFirestore.instance.collection('tailleurRequest');

  Future<void> createRequest(TailleurRequest request) async {
    final docRef = await _tailleurRef.add(request.toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<TailleurRequest?> getRequest(String id) async {
    DocumentSnapshot doc = await _tailleurRef.doc(id).get();
    try {
      if (doc.exists) {
        return TailleurRequest.fromMap(doc.data() as Map<String, dynamic>);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return null;
  }

  // get request by tailleur id
  Future<TailleurRequest?> getRequestByUserId(String userId) async {
    final querySnapshot =
        await _tailleurRef.where('userId', isEqualTo: userId).get();
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return TailleurRequest.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // get all requests by isApproved status
  Stream<List<TailleurRequest>> getRequestsByApprovalStatus(bool isApproved) {
    return _tailleurRef
        .where('isApproved', isEqualTo: isApproved)
        .snapshots()
        .map((event) => event.docs
            .map((e) =>
                TailleurRequest.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<TailleurRequest>> getPendingRequests() {
    return _tailleurRef.where('isApproved', isEqualTo: false).snapshots().map(
          (event) => event.docs
              .map((doc) =>
                  TailleurRequest.fromMap(doc.data() as Map<String, dynamic>))
              .where((request) => !request.isRejected)
              .toList(),
        );
  }

  Future<void> approveRequestAndPromoteUser({
    required TailleurRequest request,
    required String adminId,
  }) async {
    final requestId = request.id;
    if (requestId == null || requestId.isEmpty) {
      throw const FormatException('Demande tailleur introuvable.');
    }
    final batch = FirebaseFirestore.instance.batch();
    batch.update(_tailleurRef.doc(requestId), {
      'isApproved': true,
      'isRejected': false,
      'rejectionReason': '',
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
    batch.update(
        FirebaseFirestore.instance.collection('users').doc(request.userId), {
      'isTailleur': true,
      'role': 'tailor',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> rejectRequest({
    required TailleurRequest request,
    required String adminId,
    required String reason,
  }) {
    final requestId = request.id;
    if (requestId == null || requestId.isEmpty) {
      throw const FormatException('Demande tailleur introuvable.');
    }
    return _tailleurRef.doc(requestId).update({
      'isApproved': false,
      'isRejected': true,
      'rejectionReason': reason.trim(),
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRequest(String id, TailleurRequest request) {
    return _tailleurRef.doc(id).update(request.toMap());
  }

  // update request approval status
  Future<void> updateRequestApprovalStatus(String id, bool isApproved) {
    return _tailleurRef.doc(id).update({'isApproved': isApproved});
  }

  Future<void> deleteRequest(String id) {
    return _tailleurRef.doc(id).delete();
  }

  Stream<List<TailleurRequest>> getAllRequests() {
    return _tailleurRef.snapshots().map((event) => event.docs
        .map((e) => TailleurRequest.fromMap(e.data() as Map<String, dynamic>))
        .toList());
  }

  // is request already exist by userId
  Future<bool> isRequestExist(String userId) async {
    final QuerySnapshot query =
        await _tailleurRef.where('userId', isEqualTo: userId).limit(1).get();
    return query.docs.isNotEmpty;
  }
}
