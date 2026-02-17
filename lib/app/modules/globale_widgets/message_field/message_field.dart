import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/message_field/message_field_controller.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageField<T extends MessageFieldController> extends GetView<T> {
  final String parentId;
  const MessageField(this.parentId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: Row(
          children: [
            if (controller.isCommentEmpty.value)
              if (!controller.isRecordStart.value)
                _circleIcon(
                  Icons.mic,
                  controller.onRecordStart,
                  Colors.redAccent,
                )
              else
                controller.isRecordPause.value
                    ? _circleIcon(
                        Icons.mic,
                        controller.onRecordResume,
                        Colors.grey.shade400,
                        iconC: Colors.redAccent,
                      )
                    : _circleIcon(
                        Icons.pause,
                        controller.onRecordPause,
                        Colors.grey.shade400,
                      ),
            1.hs,
            Expanded(
              child: Container(
                height: 45,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                child: controller.isRecordStart.value
                    ? _recordIcons()
                    : _textField(),
              ),
            ),
            1.hs,
            !controller.onSendLoading.value
                ? _circleIcon(
                    Icons.send,
                    () {
                      controller.recordPath.isNotEmpty
                          ? controller.sendMessageVoice(parentId)
                          : controller.sendMessageText(parentId);
                    },
                    AppColors.primary,
                  )
                : circularProgress(color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Center _recordIcons() {
    return Center(
      child: Obx(() => SizedBox(
            width: 190,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Visibility(
                  visible: controller.isRecordPause.value,
                  child: controller.isPlayRecord.value
                      ? IconButton(
                          onPressed: controller.onRecordPlayPause,
                          icon: const Icon(
                            Icons.pause,
                            size: 32,
                            color: Colors.grey,
                          ))
                      : IconButton(
                          onPressed: controller.onRecordPlay,
                          icon: const Icon(
                            Icons.play_arrow,
                            size: 32,
                            color: Colors.grey,
                          )),
                ),
                Text(
                  controller.timerDisplay.value,
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                    onPressed: controller.deleteRecording,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 30,
                      color: Colors.redAccent,
                    )),
              ],
            ),
          )),
    );
  }

  Widget _textField() {
    return Obx(() => TextField(
          controller: controller.comment,
          focusNode: controller.commentFocus,
          style: const TextStyle(fontSize: 20),
          onChanged: controller.onCommentChanged,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              prefixIcon: !controller.isCommentEmpty.value
                  ? GestureDetector(
                      onTap: () {
                        controller.comment.clear();
                        controller.isCommentEmpty.value = true;
                      },
                      child: const Icon(
                        Icons.close,
                      ),
                    )
                  : null,
              suffixIcon: InkWell(
                onTap: () {
                  controller.sendMessageImage(parentId);
                },
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 25,
                ),
              ),
              disabledBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none),
        ));
  }

  Widget _circleIcon(IconData icon, Function() onPressed, Color back,
      {Color iconC = Colors.white}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: back,
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
        child: Icon(
          icon,
          size: 25,
          color: iconC,
        ),
      ),
    );
  }
}
