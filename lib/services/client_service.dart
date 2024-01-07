import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/models/client_model.dart';

class ClientService {
  final collection = FirebaseFirestore.instance.collection('client');

  // get a client by Id
  Future<Client> getClientById(String id) async {
    final doc = await collection.doc(id).get();
    return Client.fromMap(doc.data()!, doc.reference);
  }
}
