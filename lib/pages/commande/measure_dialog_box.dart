import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/pages/mesure/ajouter.dart';
import 'package:flutter/material.dart';

class MesureDialog extends StatefulWidget {
  final List<Mesure> mesures;

  MesureDialog({required this.mesures});

  @override
  _MesureDialogState createState() => _MesureDialogState();
}

class _MesureDialogState extends State<MesureDialog> {
  String searchTerm = '';
  List<Mesure> filteredMesures = [];

  @override
  void initState() {
    super.initState();
    filteredMesures = widget.mesures;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                  filteredMesures = widget.mesures.where((mesure) {
                    return mesure.nom!.contains(searchTerm);
                  }).toList();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Chercher',
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredMesures.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredMesures[index].nom!),
                    onTap: () {
                      Navigator.pop(context, filteredMesures[index].nom!);
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to mesure page
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => const AjoutMesure()));
              },
              child: const Text('Ajouter une mesure'),
            ),
          ],
        ),
      ),
    );
  }
}
