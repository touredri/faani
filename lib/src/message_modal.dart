import 'package:faani/auth.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';

import '../modele/message.dart';

class MessageModal extends StatefulWidget {
  final String idModele;
  const MessageModal({super.key, required this.idModele});

  @override
  State<MessageModal> createState() => _MessageModalState();
}

class _MessageModalState extends State<MessageModal> {
  // final User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
  }

  Stream<List<Message>> _loadData() async* {
    await for (var event in getAllMessage(widget.idModele)) {
      var messages = <Message>[];
      for (var message in event) {
        // var message = Message.fromMap(messageData, messageData.reference);
        if (message.userType == 'client') {
          var user = await getClient(message.idUser!);
          message.client = user;
        } else if (message.userType == 'tailleur') {
          var user = await getTailleur(message.idUser!);
          message.tailleur = user;
        }
        messages.add(message);
      }
      yield messages;
    }
  }

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                SizedBox(
                  height: 400,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var message = snapshot.data![index];
                      final String imgUrl = getRandomProfileImageUrl();
                      if (message.userType == 'client') {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(imgUrl),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  message.message!,
                                  style: TextStyle(color: primaryColor),
                                ),
                                subtitle:
                                    Text('par ${message.client!.nomPrenom}'),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                message.message!,
                                style: TextStyle(color: primaryColor),
                              ),
                              subtitle:
                                  Text('By ${message.tailleur!.nomPrenom}'),
                            ),
                          ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(imgUrl),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Spacer(),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Votre commentaire',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final Message message = Message(
                          idUser: user!.uid,
                          idModele: widget.idModele,
                          message: _controller.text,
                          userType: 'client',
                          id: '');
                      message.createMessage();
                      _controller.clear();
                    },
                    icon: user!.isAnonymous
                        ? const Text('')
                        : const Icon(
                            Icons.send,
                            color: primaryColor,
                          ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Une erreur est survenue: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
