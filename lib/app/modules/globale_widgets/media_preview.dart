import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPreview extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final bool autoplay;
  final bool isActive;

  const MediaPreview({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.autoplay = true,
    this.isActive = true,
  });

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  VideoPlayerController? _videoController;
  Future<void>? _videoInitFuture;

  bool get _isVideo {
    final lower = widget.url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m3u8') ||
        lower.contains('video');
  }

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(covariant MediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeVideo();
      if (_isVideo) {
        _initializeVideo();
      }
    } else if (_isVideo) {
      _syncPlayback();
    }
  }

  void _initializeVideo() {
    if (widget.url.isEmpty) return;
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _videoInitFuture = _videoController!.initialize().then((_) async {
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0);
      _syncPlayback();
      if (mounted) setState(() {});
    });
  }

  void _syncPlayback() {
    if (_videoController == null) return;
    if (widget.autoplay && widget.isActive) {
      _videoController!.play();
    } else {
      _videoController!.pause();
    }
  }

  void _disposeVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    _videoInitFuture = null;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideo || widget.url.isEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.url,
        fit: widget.fit,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => Container(
          color: AppColors.shimmerBase,
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.grey200,
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: AppColors.grey400),
          ),
        ),
      );
    }

    if (_videoController == null || _videoInitFuture == null) {
      return Container(
        color: AppColors.backgroundDark,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return FutureBuilder<void>(
      future: _videoInitFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !_videoController!.value.isInitialized) {
          return Container(
            color: AppColors.backgroundDark,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: widget.fit,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
