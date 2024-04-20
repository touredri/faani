part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const AUTH = _Paths.AUTH;
  static const ACCUEIL = _Paths.ACCUEIL;
  static const COMMANDE = _Paths.COMMANDE;
  static const FAVORIE = _Paths.FAVORIE;
  static const MESURES = _Paths.MESURES;
  static const PROFILE = _Paths.PROFILE;
  static const AJOUT_MODELE = _Paths.AJOUT_MODELE;
  // static const AJOUT_COMMANDE = _Paths.AJOUT_COMMANDE;
  static const MESSAGE = _Paths.MESSAGE;
  static const DETAIL_MODELE = _Paths.DETAIL_MODELE;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const AUTH = '/auth';
  static const ACCUEIL = '/accueil';
  static const COMMANDE = '/commande';
  static const FAVORIE = '/favorie';
  static const MESURES = '/mesures';
  static const PROFILE = '/profile';
  static const AJOUT_MODELE = '/ajout-modele';
  // static const AJOUT_COMMANDE = '/ajout-commande';
  static const MESSAGE = '/message';
  static const DETAIL_MODELE = '/detail-modele';
}
