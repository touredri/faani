import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';

import 'list_actions.dart';

class NotificationParam extends StatefulWidget {
  const NotificationParam({super.key});

  @override
  _NotificationParamState createState() => _NotificationParamState();
}

class _NotificationParamState extends State<NotificationParam> {
  bool _notificationsEnabled = true;
  bool _likenotification = true;
  bool _restacknot = true;
  bool _replinot = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: primaryBackAppBar(
        ('Notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Card(
              elevation: 0,
              child: ListTile(
                title: const Text('Push Notification',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text(
                  'Autoriser pour recevoir les alertes',
                  style: TextStyle(fontSize: 14),
                ),
                trailing: TextButton(
                  onPressed: () {}, // open phone settings
                  child: const Text('Paramètre'),
                ),
                onTap: () {}, // open phone settings
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
                    padding: EdgeInsets.only(top: 8.0, left: 15),
                    child: Text(
                      'Personnalisez',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  3.5.hs,
                  ListTile(
                    leading: const Icon(Icons.favorite_border_sharp,
                        color: Colors.grey),
                    title: const Text(
                      'J\'aimes',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: Switch(
                      value: _likenotification,
                      onChanged: (value) {
                        setState(() {
                          _likenotification = value;
                        });
                      },
                    ),
                  ),
                  3.hs,
                  ListTile(
                    leading:
                        const Icon(Icons.comment_outlined, color: Colors.grey),
                    title: const Text(
                      'Commentaires',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: Switch(
                      value: _restacknot,
                      onChanged: (value) {
                        setState(() {
                          _restacknot = value;
                        });
                      },
                    ),
                  ),
                  3.hs,
                  ListTile(
                    leading: const Icon(Icons.people_alt_outlined,
                        color: Colors.grey),
                    title: const Text(
                      'Nouveau follower',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: Switch(
                      value: _replinot,
                      onChanged: (value) {
                        setState(() {
                          _replinot = value;
                        });
                      },
                    ),
                  ),
                  3.hs,
                  ListTile(
                    leading: const Icon(Icons.send_and_archive_outlined,
                        color: Colors.grey),
                    title: const Text(
                      'Message direct',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: Switch(
                      value: _replinot,
                      onChanged: (value) {
                        setState(() {
                          _replinot = value;
                        });
                      },
                    ),
                  ),
                  3.hs,
                  ListTile(
                    leading:
                        const Icon(Icons.image_outlined, color: Colors.grey),
                    title: const Text(
                      'Modèle ajouter d\'un compte suivie',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: Switch(
                      value: _replinot,
                      onChanged: (value) {
                        setState(() {
                          _replinot = value;
                        });
                      },
                    ),
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
