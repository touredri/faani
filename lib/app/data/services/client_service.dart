import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/client_model.dart';

class ClientService {
  final collection = FirebaseFirestore.instance.collection('client');

  // get a client by Id
  Future<Client> getClientById(String id) async {
    final doc = await collection.doc(id).get();
    return Client.fromMap(doc.data()!, doc.reference);
  }

  // //update client' profile
  // Future<void> updateClientProfile(
  //     String clientId, Map<String, dynamic> data) async {
  //   final docRef = collection.doc(clientId);
  //   final docSnapshot = await docRef.get();

  //   if (docSnapshot.exists) {
  //     // The document exists, update it
  //     await docRef.update(data);
  //   } else {
  //     // The document does not exist, create it
  //     await docRef.set(data);
  //   }
  // }
}
