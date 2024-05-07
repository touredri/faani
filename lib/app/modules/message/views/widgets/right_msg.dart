import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/message_modele.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:faani/app/modules/message/views/widgets/show_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget chatRightItem(MsgContent item, BuildContext context) {
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 230.w, minWidth: 50.w),
    child: Container(
      margin: const EdgeInsets.only(top: 5, bottom: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
                ? Text(
                    item.content!,
                    style: const TextStyle(color: Colors.white),
                  )
                : ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 100.w),
                    child: GestureDetector(
                        onTap: () {
                          showImage(item.content!, context);
                        },
                        child: CachedNetworkImage(
                          imageUrl: item.content!,
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 130.w,
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
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        )),
                  ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    ),
  );
}
