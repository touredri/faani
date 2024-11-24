import 'dart:async';
import 'dart:io';
import 'package:faani/app/style/my_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class MessageFieldController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController comment = TextEditingController();
  final commentFocus = FocusNode();
  RxBool isCommentEmpty = true.obs;
  RxBool isRecordStart = false.obs;
  RxBool isRecordPlay = false.obs;
  RxBool isRecordPause = false.obs;
  RxBool isPlayRecord = false.obs;
  RxDouble recordDuration = 0.0.obs;
  RxDouble lastRecordDuration = 0.0.obs;
  RxString recordPath = ''.obs;
  RxBool onSendLoading = false.obs;

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  File? audioFile;
  File? imageFile;
  Timer? _timer;
  Timer? _playbackTimer;
  RxString timerDisplay = '0:00'.obs;

  @override
  void onInit() {
    super.onInit();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeRecorder();
    _initializePlayer();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    if (await Permission.microphone.isGranted) {
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
    } else {
      print("Microphone permission not granted");
    }
  }

  Future<void> _initializePlayer() async {
    await _player!.openPlayer().then((_) {
      _isPlayerInitialized = true; // Player is ready to use
    }).catchError((error) {
      print("Error initializing player: $error");
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordDuration.value += 1;
      timerDisplay.value = _formatDuration(recordDuration.value);
    });
  }

  String _formatDuration(double seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds.toInt() % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    recordDuration.value = 0.0;
    timerDisplay.value = '0:00';
  }

  void _retakeLastTimer() {
    recordDuration.value = lastRecordDuration.value;
    timerDisplay.value = _formatDuration(recordDuration.value);
  }

  void onCommentChanged(String value) {
    isCommentEmpty.value = value.isEmpty;
    isRecordPlay.value = false;
    isRecordStart.value = false;
  }

  Future<void> onRecordStart() async {
    if (!_isRecorderInitialized) return;
    print("Start recording");
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/temp.aac';
    await _recorder!.startRecorder(toFile: path);
    recordPath.value = path;
    isRecordStart.value = true;
    isRecordPause.value = false;
    isPlayRecord.value = false;
    _resetTimer();
    _startTimer();
  }

  Future<void> onRecordPlay() async {
    if (!_isPlayerInitialized) return;
    lastRecordDuration.value = recordDuration.value;
    if (isPlayRecord.value) {
      await _player!.pausePlayer();
    } else {
      await _player!.startPlayer(
        fromURI: recordPath.value,
        whenFinished: () {
          isPlayRecord.value = false;
          _stopPlaybackTimer();
          _retakeLastTimer();
        },
      );
      _startPlaybackTimer();
    }
    isPlayRecord.value = !isPlayRecord.value;
  }

  Future<void> onRecordPlayPause() async {
    if (!_isPlayerInitialized) return;
    await _player!.pausePlayer();
    isPlayRecord.value = false;
    _stopPlaybackTimer();
  }

  void _startPlaybackTimer() {
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordDuration.value -= 1;
      if (recordDuration.value <= 0) {
        timer.cancel();
      }
      timerDisplay.value = _formatDuration(recordDuration.value);
    });
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
  }

  Future<void> onRecordResume() async {
    if (!_isRecorderInitialized) return;
    await _recorder!.resumeRecorder();
    isRecordPause.value = false;
    _startTimer();
  }

  Future<void> onRecordPause() async {
    if (!_isRecorderInitialized || !isRecordStart.value) {
      print("Recorder is not initialized or not recording");
      return;
    }
    try {
      await _recorder!.pauseRecorder();
      isRecordPause.value = true;
      _stopTimer();
    } catch (e) {
      print("Failed to pause recorder: $e");
    }
  }

  void isPlayRecordStart() {
    isPlayRecord.value = true;
  }

  Future<void> onRecordStop() async {
    if (!_isRecorderInitialized) return;
    await _recorder!.stopRecorder();
    isRecordStart.value = false;
    isRecordPlay.value = true;
    isRecordPause.value = false;
    audioFile = File(recordPath.value);
    _stopTimer();
  }

  Future<void> deleteRecording() async {
    if (audioFile != null && await audioFile!.exists()) {
      await audioFile!.delete();
    }
    isRecordStart.value = false;
    isRecordPlay.value = false;
    isRecordPause.value = false;
    isPlayRecord.value = false;
    recordPath.value = '';
    _resetTimer();
    onRecordStop();
  }

  void checkAudio() {
    onSendLoading.value = true;
    audioFile = File(recordPath.value);
    onRecordPause();
    if (audioFile == null) {
      print("No audio file to upload");
      return;
    }
  }

  Future<bool?> showPicker(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<CroppedFile?> getAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final bool? fromGalerie = await showPicker(Get.context!);
    if (fromGalerie == null) return null;
    CroppedFile? cropedImage;
    XFile? imageFileFromGallery = await picker.pickImage(
        source:
            fromGalerie == false ? ImageSource.camera : ImageSource.gallery);
    if (imageFileFromGallery != null) {
      CroppedFile? cropImageFile =
          await _cropImageFile(imageFileFromGallery.path);
      if (cropImageFile != null) {
        cropedImage = cropImageFile;
        imageFile = File(cropedImage.path);
      }
    }
    return cropedImage;
  }

  Future<CroppedFile?> _cropImageFile(String sourcePath) async {
    final ImageCropper cropper = ImageCropper();
    return await cropper.cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Send image',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: '',
        ),
      ],
    );
  }

  // Abstract methods to be overridden by subclasses
  Future<void> sendMessageImage(String parentId);
  Future<void> sendMessageVoice(String parentId);
  Future<void> sendMessageText(String parentId);

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _player?.closePlayer();
  }
}
