// ignore_for_file: use_build_context_synchronously

import 'package:faani/app_state.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:faani/pages/commande/widget/date_picker.dart';
import 'package:faani/pages/commande/widget/join_measure.dart';
import 'package:faani/pages/commande/widget/type_habit_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/data/models/commande_model.dart';
import '../../../app/data/models/mesure_model.dart';
import '../../../app/firebase/global_function.dart';
import 'alert_box.dart';

class ClientCommandeForm extends StatefulWidget {
  final Modele modele;
  const ClientCommandeForm({super.key, required this.modele});

  @override
  State<ClientCommandeForm> createState() => _ClientCommandeFormState();
}

class _ClientCommandeFormState extends State<ClientCommandeForm> {
  DateTime? selectedDate;
  List<Categorie> categories = <Categorie>[];
  List<Mesure> mesures = [];
  String selectedCategoryId = '';
  String? selectedMesureId;
  CurrentUsers? currentUsers;

  @override
  void initState() {
    super.initState();
    categories =
        Provider.of<ApplicationState>(context, listen: false).categorie;
    mesures = Provider.of<ApplicationState>(context, listen: false).listMesures;
    currentUsers =
        Provider.of<ApplicationState>(context, listen: false).currentUsers;
    // print(currentUsers);
  }

  void onMesureSelected(String nom) async {
    Mesure? mesure = mesures.firstWhere((element) => element.nom == nom);
    setState(() {
      selectedMesureId = mesure.id;
    });
  }

  void onCategorySelected(String id) async {
    setState(() {
      selectedCategoryId = id;
    });
  }

  void create() async {
    // check if the user has already order this modele
    if (await Commande.isAlreadyOrdered(user!.uid, widget.modele.id!)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Commande'),
              content: const Text('Vous avez déjà commandé ce modèle'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
      return;
    }

    if (selectedDate != null && selectedCategoryId.isNotEmpty) {
      Commande commande = Commande(
        id: '',
        idClient: user!.uid,
        idModele: widget.modele.id!,
        dateRecuperation: selectedDate!,
        idCategorie: selectedCategoryId,
        idMesure: selectedMesureId!,
        idTailleur: widget.modele.idTailleur,
        dateCommande: DateTime.now(),
        prix: 0,
      );
      commande.create();
      AlertDialog alert = successAlert(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      AlertDialog alert = errorAlert(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      const SizedBox(
        height: 20,
      ),
      Text(
        'Renseigner les détails sur votre commande',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(
        height: 20,
      ),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Column(children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: TextField(
                            enabled: false,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: currentUsers!.numero ?? 'Numero',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                            height: 45,
                            child: SelectCategory(
                                onCategorySelected: onCategorySelected)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                              height: 45,
                              child: JoinMesureButton(
                                  mesures: mesures,
                                  onMesureSelected: onMesureSelected))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: SizedBox(
                        height: 43,
                        child: DatePickerWidget(
                          onDateSelected: (selectedDate) {
                            setState(() {
                              this.selectedDate = selectedDate;
                            });
                          },
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: () {
                      create();
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 23),
                        child: const Text('Commander')),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
            ],
          ))
    ]));
  }
}
