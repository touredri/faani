import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';

class CreateOrderInput {
  const CreateOrderInput({
    required this.requestId,
    required this.modele,
    required this.measureId,
    required this.expectedDate,
    required this.garmentFilePath,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserPhone,
    required this.currentUserToken,
    required this.isTailorFlow,
    this.selectedTailor,
    this.manualClientName = '',
    this.manualClientPhone = '',
    this.price = 0,
  });

  final String requestId;
  final Modele modele;
  final String measureId;
  final DateTime expectedDate;
  final String garmentFilePath;
  final String currentUserId;
  final String currentUserName;
  final String currentUserPhone;
  final String currentUserToken;
  final bool isTailorFlow;
  final UserModel? selectedTailor;
  final String manualClientName;
  final String manualClientPhone;
  final int price;
}

class OrderMedia {
  const OrderMedia({required this.downloadUrl, required this.storagePath});

  final String downloadUrl;
  final String storagePath;
}

abstract interface class OrderRepository {
  Future<String> create(Commande commande, {required String requestId});
  Future<void> delete(String orderId);
  Future<void> accept(String orderId);
}

abstract interface class OrderMediaService {
  Future<OrderMedia> upload(String filePath);
  Future<void> delete(String storagePath);
}

abstract interface class OrderTrackingService {
  Future<void> createInitial(String orderId, DateTime createdAt);
  Future<void> deleteForOrder(String orderId);
}

abstract interface class OrderNotificationService {
  Future<void> notifyCreated({
    required Commande commande,
    required UserModel tailor,
    required String clientName,
    required String clientToken,
  });
}

class CreateOrderException implements Exception {
  const CreateOrderException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CreateOrderUseCase {
  const CreateOrderUseCase({
    required OrderRepository orderRepository,
    required OrderMediaService mediaService,
    required OrderTrackingService trackingService,
    required OrderNotificationService notificationService,
  })  : _orderRepository = orderRepository,
        _mediaService = mediaService,
        _trackingService = trackingService,
        _notificationService = notificationService;

  final OrderRepository _orderRepository;
  final OrderMediaService _mediaService;
  final OrderTrackingService _trackingService;
  final OrderNotificationService _notificationService;

  Future<String> execute(CreateOrderInput input) async {
    _validate(input);
    OrderMedia? media;
    String? orderId;
    try {
      media = await _mediaService.upload(input.garmentFilePath);
      final tailorId =
          input.isTailorFlow ? input.currentUserId : input.selectedTailor!.id!;
      final clientPhone = input.isTailorFlow
          ? int.parse(input.manualClientPhone)
          : int.parse(input.currentUserPhone);
      final clientName = input.isTailorFlow
          ? input.manualClientName.trim()
          : input.currentUserName;
      final commande = Commande(
        id: input.requestId,
        dateAjout: DateTime.now(),
        datePrevue: input.expectedDate,
        dateModifier: input.expectedDate,
        idUser: input.isTailorFlow ? '' : input.currentUserId,
        idMesure: input.measureId,
        idModele: input.modele.id!,
        idTailleur: tailorId,
        numeroClient: clientPhone,
        nomClient: clientName,
        photoHabit: media.downloadUrl,
        refPhotoHabit: media.storagePath,
        prix: input.price,
        idCategorie: input.modele.idCategorie!,
        isSelfAdded: input.isTailorFlow,
        modeleImage: input.modele.fichier.first!,
      );
      orderId = await _orderRepository.create(
        commande,
        requestId: input.requestId,
      );
      await _trackingService.createInitial(orderId, DateTime.now());

      if (!input.isTailorFlow) {
        try {
          await _notificationService.notifyCreated(
            commande: commande,
            tailor: input.selectedTailor!,
            clientName: input.currentUserName,
            clientToken: input.currentUserToken,
          );
        } catch (_) {
          // Notifications are post-commit and must not roll back an order.
        }
      }
      return orderId;
    } catch (error) {
      if (orderId != null) {
        await _trackingService.deleteForOrder(orderId).catchError((_) {});
        await _orderRepository.delete(orderId).catchError((_) {});
      }
      if (media != null) {
        await _mediaService.delete(media.storagePath).catchError((_) {});
      }
      rethrow;
    }
  }

  void _validate(CreateOrderInput input) {
    if (input.requestId.isEmpty ||
        input.modele.id == null ||
        input.modele.id!.isEmpty ||
        input.modele.idCategorie == null ||
        input.modele.idCategorie!.isEmpty ||
        input.modele.fichier.isEmpty ||
        input.modele.fichier.first == null ||
        input.measureId.isEmpty ||
        input.garmentFilePath.isEmpty ||
        input.currentUserId.isEmpty) {
      throw const CreateOrderException('Données de commande incomplètes');
    }
    if (input.isTailorFlow) {
      if (input.manualClientName.trim().isEmpty ||
          int.tryParse(input.manualClientPhone) == null) {
        throw const CreateOrderException('Client invalide');
      }
    } else if (input.selectedTailor?.id == null ||
        input.selectedTailor!.id!.isEmpty ||
        int.tryParse(input.currentUserPhone) == null) {
      throw const CreateOrderException('Tailleur ou client invalide');
    }
  }
}
