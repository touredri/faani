import 'package:cloud_firestore/cloud_firestore.dart';
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
      print(e);
      return null;
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
    final QuerySnapshot query = await _tailleurRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}
