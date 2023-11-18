import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';

import 'firebase_get_all_data.dart';
import 'modele/mesure.dart';

class MeasurePage extends StatelessWidget {
  const MeasurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Mesures'),
      ),
      body: StreamBuilder<List<Measure>>(
        stream: getAllTailleurMesure('YclYUCHrpriv4RbAfMLu'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Une erreur est survenue');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data as List<Map<String, dynamic>>;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final mesure = data[index];
              return ListTile(
                title: Text(mesure['libelle']),
                subtitle: Text(mesure['description']),
                trailing: Text(mesure['prix']),
              );
            },
          );
        },
      ),
    );
  }
}
