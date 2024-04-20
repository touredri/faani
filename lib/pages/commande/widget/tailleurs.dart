import 'package:faani/app/data/models/tailleur_model.dart';
import 'package:flutter/material.dart';

import '../../../app/data/services/tailleur_service.dart';

class ListTailleur extends StatefulWidget {
  const ListTailleur({super.key});

  @override
  State<ListTailleur> createState() => _ListTailleurState();
}

class _ListTailleurState extends State<ListTailleur> {
  final TextEditingController _filter = TextEditingController();
  TailleurService tailleurService = TailleurService();

  @override
  void initState() {
    super.initState();
    // _filter.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: StreamBuilder<List<Tailleur>>(
              stream: tailleurService.getAllTailleur(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Text('Aucun tailleur n\'est inscrit');
                } else {
                  final List<Tailleur> tailleurs = snapshot.data!;
                  return ListView.builder(
                    itemCount: tailleurs.length,
                    itemBuilder: (context, index) {
                      return TailorCard(
                        tailleur: tailleurs[index],
                      );
                    },
                  );
                }
              }),
        ),
      ],
    );
  }
}

class TailorCard extends StatelessWidget {
  final Tailleur tailleur;

  const TailorCard({
    super.key,
    required this.tailleur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          leading: tailleur.profile.isNotEmpty
              ? Image.network(tailleur.profile)
              : SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/images/no-profile-picture.png',
                    fit: BoxFit.cover,
                  ),
                ),
          title: Text(tailleur.nomPrenom),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon(Icons.people, color: Colors.grey[600]),
                  Text(tailleur.genreHabit,
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600]),
                  Text(tailleur.quartier,
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          onTap: () {
            // Navigator.pushNamed(context, '/commande', arguments: tailleur);
          }),
    );
  }
}
