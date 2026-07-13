import 'package:faani/app/modules/message/views/discussion_view.dart';
import 'package:get/get.dart';

import '../modules/accueil/bindings/accueil_binding.dart';
import '../modules/accueil/views/accueil_view.dart';
import '../modules/ajout_modele/bindings/ajout_modele_binding.dart';
import '../modules/ajout_modele/views/ajout_modele_view.dart';
import '../modules/authentification/bindings/authentification_binding.dart';
import '../modules/authentification/views/authentification_view.dart';
import '../modules/commande/bindings/commande_binding.dart';
import '../modules/commande/views/commande_view.dart';
import '../modules/favorie/bindings/favorie_binding.dart';
import '../modules/favorie/views/favorie_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/mildware/admin_mildware.dart';
import '../modules/home/mildware/auth_mildware.dart';
import '../modules/home/views/home_view.dart';
import '../modules/message/bindings/message_binding.dart';
import '../modules/message/views/message_view.dart';
import '../modules/mesures/bindings/mesures_binding.dart';
import '../modules/mesures/views/camera_mesure_intro_view.dart';
import '../modules/mesures/views/mesures_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/widgets/received_request.dart';
import '../modules/search_page/bindings/search_page_binding.dart';
import '../modules/search_page/views/search_page_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.accueil,
      page: () => const AccueilView(),
      binding: AccueilBinding(),
    ),
    GetPage(
      name: _Paths.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.commande,
      page: () => const CommandeView(),
      binding: CommandeBinding(),
    ),
    GetPage(
      name: _Paths.favorie,
      page: () => const FavorieView(),
      binding: FavorieBinding(),
    ),
    GetPage(
        name: _Paths.mesures,
        page: () => const MesuresView(),
        binding: MesuresBinding(),
        transition: Transition.rightToLeft),
    GetPage(
      name: _Paths.cameraMesure,
      page: () => const CameraMesureIntroView(),
      binding: MesuresBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.ajoutModele,
      page: () => const AjoutModeleView(),
      binding: AjoutModeleBinding(),
    ),
    GetPage(
      name: _Paths.message,
      page: () => const MessageView(),
      binding: MessageBinding(),
    ),
    GetPage(
      name: _Paths.discussion,
      page: () => const DiscussionView(),
      binding: MessageBinding(),
    ),
    GetPage(
      name: _Paths.searchPage,
      page: () => const SearchPageView(),
      binding: SearchPageBinding(),
    ),
    GetPage(
      name: _Paths.adminPanel,
      page: () => const ReceivedRequest(),
      middlewares: [AuthMiddleware(), AdminMiddleware()],
    ),
  ];
}
