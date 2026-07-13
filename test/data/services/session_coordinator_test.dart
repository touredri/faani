import 'package:faani/app/data/services/session_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('closes only registered session components in declaration order',
      () async {
    final disposed = <String>[];
    final coordinator = ActionSessionCoordinator([
      SessionCleanupAction(
        name: 'profile',
        isRegistered: () => true,
        dispose: () => disposed.add('profile'),
      ),
      SessionCleanupAction(
        name: 'not-loaded',
        isRegistered: () => false,
        dispose: () => disposed.add('not-loaded'),
      ),
      SessionCleanupAction(
        name: 'home',
        isRegistered: () => true,
        dispose: () async => disposed.add('home'),
      ),
    ]);

    await coordinator.closeFeatureScope();

    expect(disposed, ['profile', 'home']);
  });

  test('can clean a newly registered scope after a previous session', () async {
    var isRegistered = true;
    var disposalCount = 0;
    final coordinator = ActionSessionCoordinator([
      SessionCleanupAction(
        name: 'session-component',
        isRegistered: () => isRegistered,
        dispose: () {
          disposalCount++;
          isRegistered = false;
        },
      ),
    ]);

    await coordinator.closeFeatureScope();
    await coordinator.closeFeatureScope();
    isRegistered = true;
    await coordinator.closeFeatureScope();

    expect(disposalCount, 2);
  });

  test('session A state is cleared before session B starts', () async {
    String? scopedUserId = 'user-a';
    final coordinator = ActionSessionCoordinator([
      SessionCleanupAction(
        name: 'user-state',
        isRegistered: () => scopedUserId != null,
        dispose: () => scopedUserId = null,
      ),
    ]);

    await coordinator.closeFeatureScope();
    expect(scopedUserId, isNull);

    scopedUserId = 'user-b';
    expect(scopedUserId, 'user-b');
  });
}
