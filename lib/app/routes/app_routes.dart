part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const auth = _Paths.auth;
  static const accueil = _Paths.accueil;
  static const commande = _Paths.commande;
  static const favorie = _Paths.favorie;
  static const mesures = _Paths.mesures;
  static const cameraMesure = _Paths.cameraMesure;
  static const profile = _Paths.profile;
  static const ajoutModele = _Paths.ajoutModele;
  // static const AJOUT_COMMANDE = _Paths.AJOUT_COMMANDE;
  static const message = _Paths.message;
  static const discussion = _Paths.discussion;
  static const detailModele = _Paths.detailModele;
  static const searchPage = _Paths.searchPage;
  static const adminPanel = _Paths.adminPanel;
}

abstract class _Paths {
  _Paths._();
  static const home = '/home';
  static const auth = '/auth';
  static const accueil = '/accueil';
  static const commande = '/commande';
  static const favorie = '/favorie';
  static const mesures = '/mesures';
  static const cameraMesure = '/mesures/camera';
  static const profile = '/profile';
  static const ajoutModele = '/ajout-modele';
  // static const AJOUT_COMMANDE = '/ajout-commande';
  static const message = '/message';
  static const discussion = '/discussion';
  static const detailModele = '/detail-modele';
  static const searchPage = '/search-page';
  static const adminPanel = '/admin-panel';
}
