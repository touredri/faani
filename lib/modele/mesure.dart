

class Measure {
  final int? bras;
  final int? epaule;
  final int? hanche;
  final String? idUser;
  final int? longueur;
  final int? poitrine;
  final String? nom;

  Measure({
    required this.bras,
    required this.epaule,
    required this.hanche,
    required this.idUser,
    required this.longueur,
    required this.poitrine,
    required this.nom,
  });

  Map<String, dynamic> toMap() {
    return {
      'bras': bras,
      'epaule': epaule,
      'hanche': hanche,
      'idUser': idUser,
      'longueur': longueur,
      'poitrine': poitrine,
      'nom': nom,
    };
  }

  factory Measure.fromMap(Map<String, dynamic> map) {
    return Measure(
      bras: map['bras'],
      epaule: map['epaule'],
      hanche: map['hanche'],
      idUser: map['idUser'],
      longueur: map['longueur'],
      poitrine: map['poitrine'],
      nom: map['nom'],
    );
  }
}

