// import 'package:android_intent_plus/android_intent.dart';
// import 'package:android_intent_plus/flag.dart';
import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';

class NotificationParam extends StatefulWidget {
  const NotificationParam({super.key});

  @override
  _NotificationParamState createState() => _NotificationParamState();
}

class _NotificationParamState extends State<NotificationParam> {
  bool _notificationsEnabled = true;
  bool _likenotification = true;
  bool _restacknot = false;
  bool _replinot = false;
  bool _directMessage = false;
  bool _newModeleAdded = false;

  void openNotificationSettings() {
    // const intent = AndroidIntent(
    //   action: 'android.settings.APP_NOTIFICATION_SETTINGS',
    //   flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    //   arguments: <String, dynamic>{
    //     'android.provider.extra.APP_PACKAGE': 'com.touredri.faani',
    //   },
    // );
    // intent.launch();
    // NotificationSettings.openNotificationSettings();
  }

  Widget _buildSwitchListTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        ('Notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            2.hs,
            Card(
              elevation: 0,
              child: ListTile(
                title: const Text('Push Notification',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text(
                  'Autoriser pour recevoir les alertes',
                  style: TextStyle(fontSize: 13),
                ),
                trailing: TextButton(
                  onPressed: () {
                    openNotificationSettings();
                  },
                  child: const Text('Paramètre'),
                ),
                onTap: openNotificationSettings,
              ),
            ),
            1.hs,
            Card(
              elevation: 0,
              child: ListTile(
                title: const Text(
                  'Activer les notifications',
                  style: TextStyle(fontSize: 14),
                ),
                trailing: SizedBox(
                  height: 25,
                  child: Switch(
                    splashRadius: 5,
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            1.hs,
            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 15.0, left: 17),
                    child: Text(
                      'Personnalisez',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  3.5.hs,
                  _buildSwitchListTile(
                    icon: Icons.favorite_border_sharp,
                    title: 'J\'aimes',
                    value: _likenotification,
                    onChanged: (value) {
                      setState(() {
                        _likenotification = value;
                      });
                    },
                  ),
                  3.hs,
                  _buildSwitchListTile(
                    icon: Icons.comment_outlined,
                    title: 'Commentaires',
                    value: _restacknot,
                    onChanged: (value) {
                      setState(() {
                        _restacknot = value;
                      });
                    },
                  ),
                  3.hs,
                  _buildSwitchListTile(
                    icon: Icons.people_alt_outlined,
                    title: 'Nouveau follower',
                    value: _replinot,
                    onChanged: (value) {
                      setState(() {
                        _replinot = value;
                      });
                    },
                  ),
                  3.hs,
                  _buildSwitchListTile(
                    icon: Icons.send_and_archive_outlined,
                    title: 'Message direct',
                    value: _directMessage,
                    onChanged: (value) {
                      setState(() {
                        _directMessage = value;
                      });
                    },
                  ),
                  3.hs,
                  _buildSwitchListTile(
                    icon: Icons.image_outlined,
                    title: 'Modèle ajouter d\'un compte suivie',
                    value: _newModeleAdded,
                    onChanged: (value) {
                      setState(() {
                        _newModeleAdded = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
