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
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../app/firebase/global_function.dart';
import 'comment_controller.dart';

class CommentModal extends StatefulWidget {
  final String idModele;

  const CommentModal({super.key, required this.idModele});

  @override
  State<CommentModal> createState() => _CommentModalState();
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
        final theme = Theme.of(context);
        return Material(
          color: theme.colorScheme.surface,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
                  child: Row(
                    children: [
                      Text(
                        'Commentaires',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Fermer',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.45),
                ),
                Expanded(
                  child: CommentsList(
                    commentsSnapshot: snapshot,
                    idModele: widget.idModele,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: MessageField<CommentController>(widget.idModele),
                ),
              ],
            ),
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
      final comments = commentsSnapshot.data!;
      if (comments.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.forum_outlined, size: 42, color: Colors.grey),
                SizedBox(height: 12),
                Text('Aucun commentaire'),
                SizedBox(height: 4),
                Text('Soyez le premier à réagir à ce modèle.'),
              ],
            ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];
          final String imgUrl = getRandomProfileImageUrl();
          return GestureDetector(
            onLongPress: () {
              if (comment.idUser == auth.currentUser?.uid) {
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
                final formattedDate = _formatCommentDate(comment.createdAt);
                final displayName = (user.nomPrenom ?? '').trim().isEmpty
                    ? 'Utilisateur'
                    : user.nomPrenom!.trim();
                final profileImage = (user.profileImage ?? '').trim();
                final ImageProvider<Object> avatarProvider =
                    profileImage.isNotEmpty
                        ? CachedNetworkImageProvider(profileImage)
                            as ImageProvider<Object>
                        : NetworkImage(imgUrl) as ImageProvider<Object>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: avatarProvider,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (formattedDate.isNotEmpty)
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 46),
                        child: comment.type == 'text' || comment.type == null
                            ? Text(comment.comment)
                            : comment.type == 'audio'
                                ? SizedBox(
                                    height: 45,
                                    child: AudioPlayer(source: comment.file!))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: comment.file!,
                                      height: 150,
                                      width: 110,
                                      fit: BoxFit.cover,
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

String _formatCommentDate(Timestamp? timestamp) {
  if (timestamp == null) return '';
  final date = timestamp.toDate().toLocal();
  final now = DateTime.now();
  final difference = now.difference(date);
  if (difference.inMinutes < 1) return "à l'instant";
  if (difference.inHours < 1) return 'il y a ${difference.inMinutes} min';
  if (DateUtils.isSameDay(now, date)) {
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }
  if (difference.inDays < 7) {
    return DateFormat('EEE HH:mm', 'fr_FR').format(date);
  }
  return DateFormat('d MMM yyyy', 'fr_FR').format(date);
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
