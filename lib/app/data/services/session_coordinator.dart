import 'dart:async';

abstract interface class SessionCoordinator {
  Future<void> closeFeatureScope();
}

class SessionCleanupAction {
  const SessionCleanupAction({
    required this.name,
    required this.isRegistered,
    required this.dispose,
  });

  final String name;
  final bool Function() isRegistered;
  final FutureOr<void> Function() dispose;
}

class ActionSessionCoordinator implements SessionCoordinator {
  ActionSessionCoordinator(this._actions);

  final List<SessionCleanupAction> _actions;

  @override
  Future<void> closeFeatureScope() async {
    for (final action in _actions) {
      if (!action.isRegistered()) continue;
      await action.dispose();
    }
  }
}
