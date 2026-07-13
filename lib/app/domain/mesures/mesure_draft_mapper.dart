import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/domain/mesures/mesure_draft.dart';
import 'package:faani/app/domain/mesures/mesure_field.dart';

extension MesureDraftMapper on MesureDraft {
  Mesure toMesure({required String userId, required String name}) {
    int value(MesureField field) => values[field] ?? 0;
    return Mesure(
      bras: value(MesureField.bras),
      epaule: value(MesureField.epaule),
      hanche: value(MesureField.hanche),
      idUser: userId,
      longueur: value(MesureField.longueur),
      poitrine: value(MesureField.poitrine),
      nom: name,
      taille: value(MesureField.taille),
      ventre: value(MesureField.ventre),
      poignet: value(MesureField.poignet),
      id: '',
      date: DateTime.now(),
    );
  }
}
