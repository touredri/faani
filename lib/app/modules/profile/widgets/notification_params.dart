import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationParam extends StatefulWidget {
  const NotificationParam({super.key});

  @override
  State<NotificationParam> createState() => _NotificationParamState();
}

class _NotificationParamState extends State<NotificationParam> {
  final _userService = UserService();
  var _loading = true;
  var _saving = false;
  Map<String, bool> _preferences = _defaults;

  static const _defaults = <String, bool>{
    'pushEnabled': true,
    'messageEnabled': true,
    'orderEnabled': true,
    'modelModerationEnabled': true,
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) return;
    final user = await _userService.getIfUser(userId);
    final raw = user == null ? null : user.toMap()['notificationPreferences'];
    final stored = raw is Map ? raw : const <String, dynamic>{};
    if (!mounted) return;
    setState(() {
      _preferences = {
        for (final entry in _defaults.entries)
          entry.key: stored[entry.key] is bool
              ? stored[entry.key] as bool
              : entry.value,
      };
      _loading = false;
    });
  }

  Future<void> _setPreference(String key, bool value) async {
    final userId = auth.currentUser?.uid;
    if (userId == null || _saving) return;
    setState(() {
      _preferences = {..._preferences, key: value};
      _saving = true;
    });
    try {
      await _userService.updateNotificationPreferences(userId, _preferences);
    } catch (_) {
      if (mounted) {
        setState(() => _preferences = {..._preferences, key: !value});
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: customAppBar('Notifications'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: customAppBar('Notifications'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Autorisation système'),
            subtitle: const Text('Autoriser les alertes sur cet appareil'),
            trailing: TextButton(
              onPressed: _requestPermission,
              child: const Text('Autoriser'),
            ),
          ),
          const Divider(),
          _switchTile(
            'Notifications push',
            'Conserver les activités dans l’application sans alerte appareil.',
            'pushEnabled',
          ),
          const Divider(),
          _switchTile(
              'Messages directs', 'Nouveaux messages reçus.', 'messageEnabled'),
          _switchTile('Commandes', 'Créations et changements de commande.',
              'orderEnabled'),
          _switchTile(
            'Modération des modèles',
            'Décisions de publication et de refus.',
            'modelModerationEnabled',
          ),
        ],
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, String key) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: _preferences[key] ?? true,
      onChanged: _saving ? null : (value) => _setPreference(key, value),
    );
  }
}
