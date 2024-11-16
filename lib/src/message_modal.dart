import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../app/firebase/global_function.dart';
import 'comment_controller.dart';

class CommentModal extends StatefulWidget {
  final String idModele;

  CommentModal({super.key, required this.idModele});

  @override
  _CommentModalState createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  final CommentController _commentController = Get.put(CommentController());

  @override
  void initState() {
    super.initState();
    _commentController
        .setCommentsStream(ModeleService().getComments(widget.idModele));
  }

  void _submitComment() {
    if (Get.find<AccueilController>().selectedComment.value != null) {
      ModeleService().updateComment(
        widget.idModele,
        Get.find<AccueilController>().selectedComment.value!.id,
        _commentController.controller.text,
      );
      Get.find<AccueilController>().selectedComment.value = null;
    } else {
      ModeleService().addComment(
        widget.idModele,
        _commentController.controller.text,
        auth.currentUser!.uid,
      );
    }
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Comment>>(
      stream: _commentController.commentsStream.value,
      builder: (context, snapshot) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                child: CommentsList(
                  commentsSnapshot: snapshot,
                  idModele: widget.idModele,
                ),
              ),
              InputField(
                controller: _commentController.controller,
                isTyping: _commentController.isTyping,
                onChanged: _commentController.onChanged,
                onSubmit: _submitComment,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentsList extends StatelessWidget {
  final AsyncSnapshot<List<Comment>> commentsSnapshot;
  final String idModele;

  const CommentsList({
    required this.commentsSnapshot,
    required this.idModele,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (commentsSnapshot.hasData) {
      return ListView.builder(
        itemCount: commentsSnapshot.data!.length,
        itemBuilder: (context, index) {
          var comment = commentsSnapshot.data![index];
          final String imgUrl = getRandomProfileImageUrl();
          return GestureDetector(
            onLongPress: () {
              if (comment.idUser == auth.currentUser!.uid) {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Wrap(
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Modifier'),
                          onTap: () {
                            Navigator.pop(context);
                            Get.find<AccueilController>()
                                .selectedComment
                                .value = comment;
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Supprimer'),
                          onTap: () {
                            ModeleService().removeComment(idModele, comment.id);
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    );
                  },
                );
              }
            },
            child: FutureBuilder<UserModel>(
              future: UserService().getUser(comment.idUser),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return commentShimmer();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur de connexion!'),
                  );
                }
                final user = snapshot.data!;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.profileImage ?? imgUrl),
                  ),
                  title: Text('${user.nomPrenom}',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(comment.comment,
                      style: TextStyle(color: Colors.white)),
                  trailing: user.id == auth.currentUser!.uid
                      ? IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            ModeleService().removeComment(idModele, comment.id);
                          },
                        )
                      : null,
                );
              },
            ),
          );
        },
      );
    } else if (commentsSnapshot.hasError) {
      return Center(
        child: Text('Erreur: ${commentsSnapshot.error}'),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final RxBool isTyping;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const InputField({
    required this.controller,
    required this.isTyping,
    required this.onChanged,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      margin: EdgeInsets.only(bottom: 60),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Votre commentaire',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Obx(() {
            return isTyping.value
                ? IconButton(
                    onPressed: onSubmit,
                    icon: Icon(Icons.send, color: primaryColor),
                  )
                : SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

Widget commentShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
      ),
      title: Container(
        width: 100,
        height: 20,
        color: Colors.grey[300],
      ),
      subtitle: Container(
        width: 100,
        height: 20,
        color: Colors.grey[300],
      ),
    ),
  );
}
