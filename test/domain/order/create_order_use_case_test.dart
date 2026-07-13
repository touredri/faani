import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/domain/order/create_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Modele modele() => Modele(
        id: 'modele-1',
        detail: 'Boubou',
        fichier: const ['modele.jpg'],
        imagePath: const ['images/modele.jpg'],
        genreHabit: 'mixte',
        idTailleur: 'tailleur-1',
        idCategorie: 'categorie-1',
        isPublic: true,
      );

  CreateOrderInput input({bool tailorFlow = false}) => CreateOrderInput(
        requestId: 'request-1',
        modele: modele(),
        measureId: 'mesure-1',
        expectedDate: DateTime.utc(2026, 3, 1),
        garmentFilePath: '/tmp/garment.jpg',
        currentUserId: tailorFlow ? 'tailleur-self' : 'client-1',
        currentUserName: 'Awa',
        currentUserPhone: '70000000',
        currentUserToken: 'client-token',
        isTailorFlow: tailorFlow,
        selectedTailor: tailorFlow
            ? null
            : UserModel(
                id: 'tailleur-1',
                nomPrenom: 'Moussa',
                phoneNumber: '71000000',
                token: 'tailor-token',
              ),
        manualClientName: tailorFlow ? 'Client local' : '',
        manualClientPhone: tailorFlow ? '72000000' : '',
      );

  test('creates order, initial tracking and notification', () async {
    final ports = _Ports();
    final useCase = ports.useCase();

    final orderId = await useCase.execute(input());

    expect(orderId, 'request-1');
    expect(ports.repository.created?.idTailleur, 'tailleur-1');
    expect(ports.tracking.createdOrderId, 'request-1');
    expect(ports.notifications.calls, 1);
  });

  test('rolls back order and media when initial tracking fails', () async {
    final ports = _Ports()..tracking.throwOnCreate = true;

    await expectLater(ports.useCase().execute(input()), throwsStateError);

    expect(ports.repository.deletedIds, ['request-1']);
    expect(ports.media.deletedPaths, ['images/garment.jpg']);
  });

  test('does not roll back committed order when notification fails', () async {
    final ports = _Ports()..notifications.throwOnNotify = true;

    expect(await ports.useCase().execute(input()), 'request-1');
    expect(ports.repository.deletedIds, isEmpty);
    expect(ports.media.deletedPaths, isEmpty);
  });

  test('validates tailor-entered client before uploading media', () async {
    final ports = _Ports();
    final invalid = CreateOrderInput(
      requestId: 'request-1',
      modele: modele(),
      measureId: 'mesure-1',
      expectedDate: DateTime.utc(2026, 3, 1),
      garmentFilePath: '/tmp/garment.jpg',
      currentUserId: 'tailleur-1',
      currentUserName: 'Moussa',
      currentUserPhone: '71000000',
      currentUserToken: '',
      isTailorFlow: true,
      manualClientName: '',
      manualClientPhone: 'invalid',
    );

    await expectLater(
      ports.useCase().execute(invalid),
      throwsA(isA<CreateOrderException>()),
    );
    expect(ports.media.uploadCalls, 0);
  });
}

class _Ports {
  final repository = _OrderRepository();
  final media = _MediaService();
  final tracking = _TrackingService();
  final notifications = _NotificationService();

  CreateOrderUseCase useCase() => CreateOrderUseCase(
        orderRepository: repository,
        mediaService: media,
        trackingService: tracking,
        notificationService: notifications,
      );
}

class _OrderRepository implements OrderRepository {
  Commande? created;
  final deletedIds = <String>[];

  @override
  Future<void> accept(String orderId) async {}

  @override
  Future<String> create(Commande commande, {required String requestId}) async {
    created = commande;
    return requestId;
  }

  @override
  Future<void> delete(String orderId) async => deletedIds.add(orderId);
}

class _MediaService implements OrderMediaService {
  int uploadCalls = 0;
  final deletedPaths = <String>[];

  @override
  Future<OrderMedia> upload(String filePath) async {
    uploadCalls++;
    return const OrderMedia(
      downloadUrl: 'https://example.com/garment.jpg',
      storagePath: 'images/garment.jpg',
    );
  }

  @override
  Future<void> delete(String storagePath) async =>
      deletedPaths.add(storagePath);
}

class _TrackingService implements OrderTrackingService {
  bool throwOnCreate = false;
  String? createdOrderId;

  @override
  Future<void> createInitial(String orderId, DateTime createdAt) async {
    if (throwOnCreate) throw StateError('tracking failed');
    createdOrderId = orderId;
  }

  @override
  Future<void> deleteForOrder(String orderId) async {}
}

class _NotificationService implements OrderNotificationService {
  bool throwOnNotify = false;
  int calls = 0;

  @override
  Future<void> notifyCreated({
    required Commande commande,
    required UserModel tailor,
    required String clientName,
    required String clientToken,
  }) async {
    calls++;
    if (throwOnNotify) throw StateError('notification failed');
  }
}
