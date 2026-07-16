import 'dart:io';

import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/firebase_order_services.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/mesure_service.dart';
import 'package:faani/app/data/services/order_draft_store.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/domain/order/create_order_use_case.dart';
import 'package:faani/app/domain/order/order_form_draft.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/animated_pop_up.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CommandeController extends GetxController {
  final UserController userController = Get.find();
  RxBool isSearching = false.obs;
  TextEditingController textEditingController = TextEditingController();
  final UserService userService = UserService();
  final ModeleService modeleService = ModeleService();
  final SuiviEtatService suiviEtatService = SuiviEtatService();
  final String currentEtat = 'En cours';
  final RxBool isExpanded = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isDraftLoading = false.obs;
  final RxInt orderFormStep = 0.obs;
  final ScrollController scrollController = ScrollController();
  final List<Modele> modeles = [];
  Rx<XFile?> image = Rx<XFile?>(null);
  final Rx<Mesure?> mesure = Rx<Mesure?>(null);
  final RxString selectedDate = ''.obs;
  final TextEditingController prixController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  RxList<String> listSelectedCategorie = <String>[].obs;
  late final CreateOrderUseCase _createOrder;
  late final OrderRepository _orderRepository;
  late final OrderDraftStore _draftStore;

  CommandeController({
    CreateOrderUseCase? createOrder,
    OrderRepository? orderRepository,
    OrderDraftStore? draftStore,
  }) {
    _orderRepository = orderRepository ?? FirestoreOrderRepository();
    _draftStore = draftStore ?? OrderDraftStore();
    _createOrder = createOrder ??
        CreateOrderUseCase(
          orderRepository: _orderRepository,
          mediaService: FirebaseOrderMediaService(),
          trackingService: FirebaseOrderTrackingService(suiviEtatService),
          notificationService: const FirebaseOrderNotificationService(),
        );
  }

  Future<List<dynamic>> fetchCommandeData(Commande commande) async {
    return Future.wait([
      userService.getUser(commande.idTailleur),
      commande.idUser.isNotEmpty
          ? userService.getUser(commande.idUser)
          : Future.value(null),
      modeleService.getModeleById(commande.idModele),
      suiviEtatService.getSuiviEtatByCommandeId(commande.id!)
    ]);
  }

  void onCategorieSelected(Categorie categorie) {
    if (listSelectedCategorie.contains(categorie.id)) {
      listSelectedCategorie.remove(categorie.id);
    } else {
      listSelectedCategorie.add(categorie.id);
    }
    update();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    update(['search']);
  }

  // The listener function that will be called when the user scrolls
  void _onScroll() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        modeles.isNotEmpty) {
      modeleService
          .getAllModeleByTailleur(userController.currentUser.value.id!, [],
              lastModele: modeles.last)
          .then((event) {
        for (var element in event) {
          if (!modeles.contains(element)) {
            modeles.add(element);
          }
        }
      });
    }
  }

  void clearForm() {
    image.value = null;
    selectedDate.value = '';
    mesure.value = null;
    nomController.clear();
    numeroController.clear();
    prixController.clear();
    orderFormStep.value = 0;
  }

  Future<void> prepareOrderForm(Modele modele, {UserModel? tailleur}) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;
    isDraftLoading.value = true;
    try {
      final draft = await _draftStore.read(currentUser.uid);
      if (draft == null ||
          draft.modeleId != (modele.id ?? '') ||
          draft.tailleurId != (tailleur?.id ?? '')) {
        clearForm();
        return;
      }

      image.value =
          draft.photoPath.isEmpty || !File(draft.photoPath).existsSync()
              ? null
              : XFile(draft.photoPath);
      selectedDate.value = draft.expectedDate;
      nomController.text = draft.clientName;
      numeroController.text = draft.clientPhone;
      prixController.text = draft.price;
      orderFormStep.value = draft.photoPath.isEmpty ? 0 : 1;
      if (draft.mesureId.isNotEmpty) {
        try {
          mesure.value = await MesureService().getById(draft.mesureId).first;
        } catch (_) {
          mesure.value = null;
        }
      }
    } finally {
      isDraftLoading.value = false;
    }
  }

  Future<void> saveOrderDraft(Modele modele, {UserModel? tailleur}) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;
    await _draftStore.save(
      currentUser.uid,
      OrderFormDraft(
        modeleId: modele.id ?? '',
        tailleurId: tailleur?.id ?? '',
        photoPath: image.value?.path ?? '',
        mesureId: mesure.value?.id ?? '',
        expectedDate: selectedDate.value,
        clientName: nomController.text.trim(),
        clientPhone: numeroController.text.trim(),
        price: prixController.text.trim(),
      ),
    );
  }

  Future<void> clearOrderDraft() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      await _draftStore.clear(currentUser.uid);
    }
  }

  // create a new commande
  Future<bool> createCommande(Modele modele, {UserModel? tailleur}) async {
    if (image.value == null || !File(image.value!.path).existsSync()) {
      showCustomSnackbar(message: 'Veuillez ajouter une photo de l\'habit');
      return false;
    }

    if (mesure.value?.id == null || selectedDate.value.isEmpty) {
      showCustomSnackbar(message: 'Veuillez renseigner les mesures et la date');
      return false;
    }

    final currentUser = auth.currentUser;
    if (currentUser == null) {
      showCustomSnackbar(message: 'Veuillez vous reconnecter');
      return false;
    }

    if (userController.currentUser.value.id == null ||
        userController.currentUser.value.id!.isEmpty) {
      await userController.init();
    }

    final String resolvedUserId =
        (userController.currentUser.value.id ?? '').isNotEmpty
            ? userController.currentUser.value.id!
            : currentUser.uid;

    final bool isTailleurFlow = userController.isTailleur.value;
    if (isTailleurFlow) {
      final clientName = nomController.text.trim();
      final clientPhone = numeroController.text.trim();
      final parsedPhone = int.tryParse(clientPhone);
      if (clientName.isEmpty || clientPhone.isEmpty || parsedPhone == null) {
        showCustomSnackbar(
          message: 'Veuillez renseigner un nom et un numéro client valide',
        );
        return false;
      }
    }

    if (!isTailleurFlow && tailleur == null) {
      showCustomSnackbar(message: 'Veuillez choisir un tailleur');
      return false;
    }

    isSending.value = true;
    try {
      final currentProfile = userController.currentUser.value;
      await _createOrder.execute(
        CreateOrderInput(
          requestId:
              '$resolvedUserId-${modele.id}-${DateTime.now().microsecondsSinceEpoch}',
          modele: modele,
          measureId: mesure.value!.id!,
          expectedDate: DateTime.parse(selectedDate.value),
          garmentFilePath: image.value!.path,
          currentUserId: resolvedUserId,
          currentUserName: currentProfile.nomPrenom ?? '',
          currentUserPhone: currentProfile.phoneNumber ?? '',
          currentUserToken: currentProfile.token ?? '',
          isTailorFlow: isTailleurFlow,
          selectedTailor: tailleur,
          manualClientName: nomController.text,
          manualClientPhone: numeroController.text,
          price: int.tryParse(prixController.text) ?? 0,
        ),
      );
      await clearOrderDraft();
      animatedPopUp(
          Get.context!,
          0.2,
          0.8,
          Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(
                height: 20,
              ),
              Text(
                userController.isTailleur.value
                    ? 'Enregistrer avec succès'
                    : 'Envoyé au tailleur avec succès',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                    Get.back();
                  },
                  child: const Text('Ok'))
            ],
          ));
      clearForm();
      return true;
    } on CreateOrderException catch (error) {
      showCustomSnackbar(message: error.message);
      return false;
    } catch (_) {
      showCustomSnackbar(
        message: 'La commande n\'a pas pu être créée. Veuillez réessayer.',
      );
      return false;
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.removeListener(_onScroll);
    modeles.clear();
  }

  void changePrice(Commande commande, {required BuildContext context}) {
    if (commande.prix == 0 && userController.isTailleur.value) {
      final TextEditingController prix = TextEditingController();
      Get.defaultDialog(
        title: 'Ajouter le Prix',
        content: Column(
          children: [
            TextField(
              controller: prix,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prix',
                hintText: 'Entrer le prix',
              ),
            ),
            1.hs,
            ElevatedButton(
              onPressed: () async {
                final value = int.tryParse(prix.text.trim());
                if (value == null || value < 0) {
                  showCustomSnackbar(message: 'Veuillez saisir un prix valide');
                  return;
                }
                commande.prix = value;
                await commande.update();
                Get.snackbar('Succèss', 'Le prix à été modifier avec succès 👍',
                    snackPosition: SnackPosition.BOTTOM);
                if (commande.idUser.isNotEmpty) {
                  UserModel client = await userService.getUser(commande.idUser);
                  final token = client.token;
                  if (token != null && token.isNotEmpty) {
                    await sendNotification(
                      token,
                      'Prix modifié',
                      'Le tailleur ${userController.currentUser.value.nomPrenom} a modifié le prix de votre commande à ${prix.text} FCFA',
                      category: 'order',
                      targetType: 'commande',
                      targetId: commande.id ?? '',
                    );
                  }
                }
                Get.back();
                update();
              },
              child: const Text('Valider'),
            )
          ],
        ),
      );
    } else if (commande.prix != 0 && userController.isTailleur.value) {
      showCustomSnackbar(message: 'Vous ne pouvez pas modifier le prix encore');
    } else {
      showCustomSnackbar(
          message: 'Vous n\'êtes pas autorisé à modifier le prix');
    }
  }

  void changeDate(Commande commande, {required BuildContext context}) async {
    if (userController.isTailleur.value && user!.uid == commande.idTailleur) {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 2),
      );
      if (date != null) {
        commande.datePrevue = date;
        await commande.update();
        Get.snackbar('Succèss', 'La date prevue à été changé avec succès 👍',
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      showCustomSnackbar(
          message: "Vous n'êtes pas autorisé à modifier la date");
    }
    update();
  }

  Future<void> acceptCommande(Commande commande) async {
    if (userController.isTailleur.value && user!.uid == commande.idTailleur) {
      await _orderRepository.accept(commande.id!);
      commande.isAccepted = true;
      update(['commande']);
    }
  }
}
