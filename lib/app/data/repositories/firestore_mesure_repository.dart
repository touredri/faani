import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/domain/mesures/mesure_repository.dart';

class FirestoreMesureRepository implements MesureRepository {
  FirestoreMesureRepository({FirebaseFirestore? firestore})
      : _collection =
            (firestore ?? FirebaseFirestore.instance).collection('mesure');

  final CollectionReference<Map<String, dynamic>> _collection;

  @override
  Future<String> create(Mesure mesure) async {
    final docRef = await _collection.add(mesure.toMap());
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }
}
