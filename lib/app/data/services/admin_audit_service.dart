import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/firebase/global_function.dart';

class AdminAuditService {
  final CollectionReference _auditRef =
      FirebaseFirestore.instance.collection('adminAuditLogs');

  Future<void> logAction({
    required String action,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? metadata,
  }) async {
    final adminId = auth.currentUser?.uid ?? '';
    await _auditRef.add({
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'adminId': adminId,
      'metadata': metadata ?? <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getRecentLogs({int limit = 120}) {
    return _auditRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (event) => event.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }
}
