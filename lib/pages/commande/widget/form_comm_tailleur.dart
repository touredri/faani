import 'package:faani/app_state.dart';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/pages/commande/widget/alert_box.dart';
import 'package:faani/pages/commande/widget/date_picker.dart';
import 'package:faani/pages/commande/widget/join_measure.dart';
import 'package:faani/pages/commande/widget/type_habit_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../helpers/authentification.dart';
import '../../../app/data/models/commande_model.dart';
import '../../../app/data/models/mesure_model.dart';
import '../../../my_theme.dart';

class TailleurCommandeForm extends StatefulWidget {
  final Modele modele;
  const TailleurCommandeForm({super.key, required this.modele});

  @override
  State<TailleurCommandeForm> createState() => _TailleurCommandeFormState();
}

class _TailleurCommandeFormState extends State<TailleurCommandeForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  DateTime? selectedDate;
  String selectedCategoryId = '';
  List<Categorie> categories = <Categorie>[];
  List<Mesure> mesures = [];
  String? selectedMesureId;

  @override
  void initState() {
    super.initState();
    categories =
        Provider.of<ApplicationState>(context, listen: false).categorie;
    mesures = Provider.of<ApplicationState>(context, listen: false).listMesures;
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
    if (_nameController.text.isNotEmpty &&
        _numeroController.text.isNotEmpty &&
        _prixController.text.isNotEmpty &&
        selectedDate != null &&
        selectedCategoryId.isNotEmpty) {
      CommandeAnonyme commandeAnonyme = CommandeAnonyme(
        id: '',
        idModele: widget.modele.id,
        nomClient: _nameController.text,
        numeroClient: int.parse(_numeroController.text),
        prix: int.parse(_prixController.text),
        dateRecuperation: selectedDate,
        idCategorie: selectedCategoryId,
        idMesure: selectedMesureId,
        idTailleur: user!.uid,
        dateCommande: DateTime.now(),
        image: widget.modele.fichier[0],
      );
      commandeAnonyme.create();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Column(children: [
            const SizedBox(height: 30),
            Text(
              'Renseignez les informations de la commande',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _nameController,
                      maxLength: 30,
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Prénom Nom',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro',
                        counterText: '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _prixController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Prix',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child:
                        SelectCategory(onCategorySelected: onCategorySelected),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: SizedBox(
                        height: 50,
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
                  child: const Text('Enregistrer')),
            ),
          ]),
        ),
      ],
    );
  }
}
