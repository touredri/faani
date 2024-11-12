class TailleurRequest {
  String? id;
  String userId, nomAtelier, clientCible, pays, ville, quartier;
  int nombreTravailleur, numAtelier;
  bool isApproved; // New property

  TailleurRequest({
    this.id,
    required this.userId,
    required this.nomAtelier,
    required this.clientCible,
    required this.pays,
    required this.ville,
    required this.quartier,
    required this.nombreTravailleur,
    required this.numAtelier,
    this.isApproved = false,
  });

  factory TailleurRequest.fromMap(Map<String, dynamic> map) {
    return TailleurRequest(
      id: map['id'],
      userId: map['userId'],
      nomAtelier: map['nomAtelier'],
      clientCible: map['clientCible'],
      pays: map['pays'],
      ville: map['ville'],
      quartier: map['quartier'],
      nombreTravailleur: map['nombreTravailleur'],
      numAtelier: map['numAtelier'],
      isApproved: map['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'nomAtelier': nomAtelier,
      'clientCible': clientCible,
      'pays': pays,
      'ville': ville,
      'quartier': quartier,
      'nombreTravailleur': nombreTravailleur,
      'numAtelier': numAtelier,
      'isApproved': isApproved,
    };
  }
}
