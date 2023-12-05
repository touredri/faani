import 'package:faani/auth.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/src/ajout_mesure.dart';
import 'package:faani/src/mesure_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'firebase_get_all_data.dart';
import 'modele/mesure.dart';

class MeasurePage extends StatelessWidget {
  const MeasurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: primaryColor,
          title: const Text(
            'Mesures',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        body: StreamBuilder<List<Measure>>(
          stream: getAllTailleurMesure(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Une erreur est survenue');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                'Aucune mesure disponible! Ajouter une mesure',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ));
            }
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final mesure = data[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            DetailMesure(mesure: mesure.id!)));
                  },
                  child: ListTile(
                    title: Text(mesure.nom!),
                    subtitle: Text(DateFormat('yyyy-MM-dd')
                        .format(mesure.date!)
                        .toString()),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AjoutMesure()));
          },
          child: const Icon(Icons.add),
        ));
  }
}