import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/message_field/audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget messageCard({
  required BuildContext context,
  required String parentId,
  required String ownerName,
  required String type,
  required String userId,
  String? commentId,
  String? ownerPhotoUrl,
  String? ownerId,
  String? content,
  String? fileUrl,
  List<String>? reporterIds,
  DateTime? createDate,
  Function(String parentId, String commentId)? onDelete,
  Function(String userId, String commentId)? onReport,
}) {
  final formattedDate =
                            timeago.format(createDate ?? DateTime.now(), locale: 'fr_short');
  return ListTile(
    title: Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage((ownerPhotoUrl?.isEmpty ?? true)
              ? 'https://via.placeholder.com/400x300?text=${(ownerName.substring(0, 2).toUpperCase())}'
              : ownerPhotoUrl!),
        ),
        3.ws,
        Text(
          ownerName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(left: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (type == 'text')
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                content ?? '',
                maxLines: 30,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (type == 'audio' && fileUrl != null)
            AudioPlayer(
              key: Key(parentId),
              source: fileUrl,
            ),
          if (type == 'image' && fileUrl != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 350),
              child: GestureDetector(
                onTap: () {
                  // showImage(item.content!, context);
                },
                child: CachedNetworkImage(
                  imageUrl: fileUrl,
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 300,
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              ownerId == userId
                  ? InkWell(
                      onTap: () => onDelete?.call(parentId, commentId!),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        onReport?.call(userId, commentId!);
                      },
                      child: Icon(
                        (reporterIds ?? []).contains(userId)
                            ? Icons.report
                            : Icons.report_outlined,
                        color: (reporterIds ?? []).contains(userId)
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
              Expanded(
                flex: 3,
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const Divider(
            height: 1,
          ),
        ],
      ),
    ),
  );
}
