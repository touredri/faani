import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/tailor_client_measure.dart';

class TailorClientMeasureService {
  final CollectionReference _measuresRef =
      FirebaseFirestore.instance.collection('tailorClientMeasures');

  Stream<List<TailorClientMeasure>> getMeasuresByClient({
    required String tailorId,
    required String clientId,
  }) {
    return _measuresRef
        .where('tailorId', isEqualTo: tailorId)
        .where('clientId', isEqualTo: clientId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((doc) => TailorClientMeasure.fromMap(
                doc.data() as Map<String, dynamic>, doc.reference))
            .toList());
  }

  Future<String> createMeasure(TailorClientMeasure measure) async {
    final docRef = await _measuresRef.add(measure.toMap());
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  Future<void> updateMeasure(TailorClientMeasure measure) {
    return _measuresRef.doc(measure.id).update(measure.toMap());
  }

  Future<void> deleteMeasure(String measureId) {
    return _measuresRef.doc(measureId).delete();
  }
}
