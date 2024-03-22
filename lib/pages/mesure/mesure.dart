import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/pages/mesure/ajouter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail.dart';

class MesurePage extends StatelessWidget {
  const MesurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: scaffoldBack,
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
        body: StreamBuilder<List<Mesure>>(
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
