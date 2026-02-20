import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/message_modele.dart';
import 'package:faani/app/modules/globale_widgets/message_field/audio.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:faani/app/modules/message/views/widgets/show_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

Widget chatRightItem(MsgContent item, BuildContext context) {
  final time = item.addtime != null
      ? DateFormat('HH:mm', 'fr_FR').format(item.addtime!.toDate())
      : '';

  return Container(
    margin: const EdgeInsets.only(top: 5, bottom: 10, right: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.type == 'text'
                    ? const Color.fromARGB(255, 235, 148, 133)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: item.type == "text"
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.62,
                      ),
                      child: Text(
                        item.content ?? '',
                        softWrap: true,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : item.type == "image"
                      ? ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 300.w),
                          child: GestureDetector(
                              onTap: () {
                                showImage(item.content!, context);
                              },
                              child: CachedNetworkImage(
                                imageUrl: item.content!,
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 200.w,
                                  height: 170.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => shimmer(),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              )),
                        )
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.72,
                          ),
                          child: SizedBox(
                            height: 45,
                            child: AudioPlayer(source: item.content!),
                          ),
                        ),
            ),
            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 4),
                child: Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
          ],
        ),
        const SizedBox(width: 5),
      ],
    ),
  );
}
