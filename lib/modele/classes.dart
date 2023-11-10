
import 'dart:ffi';

class Utilisateur {
  String nomPrenom;
  Long telephone;
  String genre;

  Utilisateur(this.nomPrenom, this.telephone, this.genre);
}

class Tailleur extends Utilisateur {
  String quartier;
  String genreHabit;
  bool isVerify;

  Tailleur(this.quartier, this.genreHabit, this.isVerify, nomPrenom, telephone,
      genre)
      : super(nomPrenom, telephone, genre);
}

class Client extends Utilisateur {
  Client(super.nomPrenom, super.telephone, super.genre);
}

class Commande {
  DateTime date;
  DateTime dateRecuperation;
  int idClient;
  int idTailleur;
  int idMesure;
  int idModele;
  
  Commande(this.date, this.dateRecuperation, this.idClient, this.idTailleur, this.idMesure, this.idModele);

  void ajouterCommande() {}

  void modifierCommande() {}

  void changeDateRecuperation() {}
}

// class Modele {
  
// }

class Mesure {
  
}

