import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/follow.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:get/get.dart';

class DetailModeleController extends GetxController {
  DetailModeleController({
    UserService? userService,
    ModeleService? modeleService,
    FollowService? followService,
  })  : _userService = userService ?? UserService(),
        _modeleService = modeleService ?? ModeleService(),
        _followService = followService ?? FollowService();

  final UserService _userService;
  final ModeleService _modeleService;
  final FollowService _followService;
  final UserController userController = Get.find<UserController>();
  final Rxn<UserModel> modeleUser = Rxn<UserModel>();
  final RxList<Modele> relatedModeles = <Modele>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isAuthor = false.obs;
  final RxBool isFollowing = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isTailleur => userController.isTailleur.value;

  Future<void> load(Modele modele) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (modele.isFaaniContent) {
        modeleUser.value = null;
        isAuthor.value = false;
        isFollowing.value = false;
        await _loadRelated(modele);
      } else {
        await Future.wait<void>([
          _loadOwner(modele.idTailleur),
          _loadRelated(modele),
        ]);
        await _loadFollowStatus(modele.idTailleur);
      }
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOwner(String tailorId) async {
    final owner = await _userService.getUser(tailorId);
    modeleUser.value = owner;
    isAuthor.value = auth.currentUser?.uid == tailorId;
  }

  Future<void> _loadRelated(Modele modele) async {
    final categoryId = modele.idCategorie;
    if (categoryId == null || categoryId.isEmpty) {
      relatedModeles.clear();
      return;
    }
    final page = await _modeleService.searchDiscoverable(
      query: '',
      categoryId: categoryId,
      pageSize: 8,
    );
    relatedModeles.assignAll(
      page.items.where((item) => item.id != modele.id),
    );
  }

  Future<void> _loadFollowStatus(String tailorId) async {
    final currentUser = auth.currentUser;
    if (currentUser == null ||
        currentUser.isAnonymous ||
        currentUser.uid == tailorId) {
      isFollowing.value = false;
      return;
    }
    isFollowing.value =
        await _followService.isFollowing(currentUser.uid, tailorId);
  }

  Future<void> toggleFollowStatus(String tailorId) async {
    final currentUser = auth.currentUser;
    if (currentUser == null ||
        currentUser.isAnonymous ||
        currentUser.uid == tailorId) {
      return;
    }
    final nextStatus = !isFollowing.value;
    isFollowing.value = nextStatus;
    try {
      await _followService.updateFollowStatus(
          currentUser.uid, tailorId, nextStatus);
    } catch (_) {
      isFollowing.value = !nextStatus;
      rethrow;
    }
  }
}
