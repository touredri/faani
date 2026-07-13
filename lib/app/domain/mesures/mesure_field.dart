/// Identifiants des mesures Faani (centimètres).
enum MesureField {
  epaule,
  bras,
  hanche,
  longueur,
  poitrine,
  taille,
  ventre,
  poignet,
}

extension MesureFieldX on MesureField {
  String get key => name;

  String get label {
    switch (this) {
      case MesureField.epaule:
        return 'Epaule';
      case MesureField.bras:
        return 'Bras';
      case MesureField.hanche:
        return 'Hanche';
      case MesureField.longueur:
        return 'Longueur';
      case MesureField.poitrine:
        return 'Poitrine';
      case MesureField.taille:
        return 'Taille';
      case MesureField.ventre:
        return 'Ventre';
      case MesureField.poignet:
        return 'Poignet';
    }
  }

  String get imageAsset {
    switch (this) {
      case MesureField.epaule:
        return 'assets/images/epaules.jpg';
      case MesureField.bras:
        return 'assets/images/bras.jpg';
      case MesureField.hanche:
        return 'assets/images/hanche.jpg';
      case MesureField.longueur:
        return 'assets/images/longueur.jpg';
      case MesureField.poitrine:
        return 'assets/images/poitrine.jpg';
      case MesureField.taille:
        return 'assets/images/taille.jpg';
      case MesureField.ventre:
        return 'assets/images/ventre.jpg';
      case MesureField.poignet:
        return 'assets/images/poignet.jpg';
    }
  }

  static MesureField? tryParse(String value) {
    for (final field in MesureField.values) {
      if (field.key == value) {
        return field;
      }
    }
    return null;
  }
}

/// Champs proposés automatiquement lorsque les captures sont suffisamment fiables.
const cameraAutoFields = <MesureField>{
  MesureField.epaule,
  MesureField.bras,
  MesureField.hanche,
  MesureField.longueur,
  MesureField.poitrine,
  MesureField.taille,
  MesureField.ventre,
  MesureField.poignet,
};

/// Les champs non fiables restent dans le repli manuel.
const cameraManualFields = <MesureField>{};
