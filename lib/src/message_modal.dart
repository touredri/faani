import 'package:faani/app/data/services/comment_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import '../app/data/models/comment_modele.dart';
import '../app/firebase/global_function.dart';

class CommentModal extends StatefulWidget {
  final String idModele;
  const CommentModal({super.key, required this.idModele});

  @override
  State<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  @override
  void initState() {
    super.initState();
  }

  Stream<List<Comment>> _loadData() async* {
    await for (var event in CommentService().getAllMessage(widget.idModele)) {
      var comments = <Comment>[];
      for (var comment in event) {
        if (comment.role == 'client') {
          var user = await UserService().getUser(comment.idUser!);
          comment.client = user;
        } else if (comment.role == 'tailleur') {
          var user = await UserService().getUser(comment.idUser!);
          comment.tailleur = user;
        }
        comments.add(comment);
      }
      yield comments;
    }
  }

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Comment>>(
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
                      var comment = snapshot.data![index];
                      final String imgUrl = getRandomProfileImageUrl();
                      if (comment.role == 'client') {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(imgUrl),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  comment.comment!,
                                  style: TextStyle(color: primaryColor),
                                ),
                                subtitle:
                                    Text('par ${comment.client!.nomPrenom}'),
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
                                comment.comment!,
                                style: TextStyle(color: primaryColor),
                              ),
                              subtitle:
                                  Text('By ${comment.tailleur!.nomPrenom}'),
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
                        decoration: const InputDecoration(
                          hintText: 'Votre commentaire',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final Comment comment = Comment(
                          idUser: auth.currentUser!.uid,
                          idModele: widget.idModele,
                          comment: _controller.text,
                          role: 'client',
                          id: '');
                      comment.createComment();
                      _controller.clear();
                    },
                    icon: auth.currentUser!.isAnonymous
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
