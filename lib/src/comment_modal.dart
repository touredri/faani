import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/modules/globale_widgets/message_field/audio.dart';
import 'package:faani/app/modules/globale_widgets/message_field/message_field.dart';
import 'package:flutter/material.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../app/firebase/global_function.dart';
import 'comment_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Comment>>(
      stream: _commentController.commentsStream.value,
      builder: (context, snapshot) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              Expanded(
                child: CommentsList(
                  commentsSnapshot: snapshot,
                  idModele: widget.idModele,
                ),
              ),
              MessageField<CommentController>(widget.idModele),
              1.hs,
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
                  useRootNavigator: true,
                  isScrollControlled: true,
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
                            ModeleService()
                                .removeComment(idModele, comment.id!);
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
                final formattedDate = timeago.format(
                    (comment.createdAt ?? Timestamp.now()).toDate(),
                    locale: 'fr_short');
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(user.profileImage ?? imgUrl),
                              ),
                              2.5.ws,
                              Text(
                                '${user.nomPrenom}',
                              ),
                            ],
                          ),
                          Text(formattedDate,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ))
                        ],
                      ),
                      1.hs,
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: comment.type == "text" || comment.type == null
                            ? Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                child: Text(
                                  overflow: TextOverflow.clip,
                                  comment.comment,
                                ),
                              )
                            : comment.type == "audio"
                                ? SizedBox(
                                    height: 45,
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: AudioPlayer(source: comment.file!))
                                : SizedBox(
                                    height: 150,
                                    width: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                          imageUrl: comment.file!,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                      ),
                    ],
                  ),
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
