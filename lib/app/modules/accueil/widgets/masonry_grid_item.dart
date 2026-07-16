import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_shadows.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:faani/app/data/services/favorite_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

/// A single masonry grid item card for the home exploration grid.
///
/// Shows: image thumbnail, title, fabric type, and save icon.
/// Subtle radius, soft shadow, minimal overlay.
class MasonryGridItem extends StatefulWidget {
  final Modele modele;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const MasonryGridItem({
    super.key,
    required this.modele,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<MasonryGridItem> createState() => _MasonryGridItemState();
}

class _MasonryGridItemState extends State<MasonryGridItem> {
  bool _pressed = false;
  double? _resolvedAspectRatio;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  bool get _hasVideoMedia {
    final media = widget.modele.fichier.isNotEmpty
        ? (widget.modele.fichier[0] ?? '')
        : '';
    final lower = media.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('video');
  }

  @override
  void initState() {
    super.initState();
    _resolveImageAspectRatio();
  }

  @override
  void didUpdateWidget(covariant MasonryGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldMedia = oldWidget.modele.fichier.isNotEmpty
        ? oldWidget.modele.fichier.first
        : null;
    final newMedia =
        widget.modele.fichier.isNotEmpty ? widget.modele.fichier.first : null;
    if (oldMedia != newMedia) {
      _resolvedAspectRatio = null;
      _resolveImageAspectRatio();
    }
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    super.dispose();
  }

  void _resolveImageAspectRatio() {
    if (_hasVideoMedia) return;
    final mediaUrl = widget.modele.fichier.isNotEmpty
        ? (widget.modele.fichier.first ?? '')
        : '';
    if (mediaUrl.isEmpty) return;
    final storedRatio = widget.modele.mediaAspectRatios.isNotEmpty
        ? widget.modele.mediaAspectRatios.first
        : null;
    if (storedRatio != null && storedRatio > 0) {
      _resolvedAspectRatio = storedRatio;
      return;
    }
    _imageStream =
        CachedNetworkImageProvider(mediaUrl).resolve(ImageConfiguration.empty);
    _imageListener = ImageStreamListener((image, _) {
      final ratio = image.image.width / image.image.height;
      if (mounted && ratio > 0) setState(() => _resolvedAspectRatio = ratio);
    });
    _imageStream!.addListener(_imageListener!);
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _resolvedAspectRatio ?? 0.8;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusMd,
              boxShadow: AppShadows.sm,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.radiusMd,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Image ────────────────────────────────────────
                  _MasonryMedia(
                    mediaUrl: widget.modele.fichier.isNotEmpty
                        ? widget.modele.fichier[0]!
                        : '',
                  ),

                  // ── Bottom gradient overlay ──────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 72,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Text info ────────────────────────────────────
                  Positioned(
                    bottom: AppSpacing.sm,
                    left: AppSpacing.sm,
                    right: AppSpacing.huge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.modele.isFaaniContent)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'FAANI',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        if (widget.modele.detail != null &&
                            widget.modele.detail!.isNotEmpty)
                          Text(
                            widget.modele.detail!,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 2),
                        Text(
                          widget.modele.genreHabit,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.white.withValues(alpha: 0.7),
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  // ── Save icon (top-right) ────────────────────────
                  if (widget.modele.id != null)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: _ModeleSaveButton(modeleId: widget.modele.id!),
                    ),

                  if (_hasVideoMedia)
                    Positioned(
                      bottom: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MasonryMedia extends StatefulWidget {
  const _MasonryMedia({required this.mediaUrl});

  final String mediaUrl;

  @override
  State<_MasonryMedia> createState() => _MasonryMediaState();
}

class _MasonryMediaState extends State<_MasonryMedia> {
  bool get _isVideo {
    final lower = widget.mediaUrl.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('video');
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      return _VideoPoster(mediaUrl: widget.mediaUrl);
    }

    return CachedNetworkImage(
      imageUrl: widget.mediaUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 400),
      fadeInCurve: Curves.easeIn,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.grey200,
        highlightColor: AppColors.grey100,
        child: Container(color: AppColors.grey200),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.grey200,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: AppColors.grey400, size: 28),
        ),
      ),
    );
  }
}

class _VideoPoster extends StatefulWidget {
  const _VideoPoster({required this.mediaUrl});
  final String mediaUrl;

  @override
  State<_VideoPoster> createState() => _VideoPosterState();
}

class _VideoPosterState extends State<_VideoPoster> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
    _controller!.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Container(color: AppColors.grey200),
    );
  }
}

class _ModeleSaveButton extends StatelessWidget {
  const _ModeleSaveButton({required this.modeleId});
  final String modeleId;

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const _SaveIconButton(isSaved: false);
    }
    final userId = user?.uid;
    if (userId == null || user?.isAnonymous == true) {
      return _SaveIconButton(
        isSaved: false,
        onPressed: () => showCustomSnackbar(message: 'home_login_to_save'.tr),
      );
    }
    return StreamBuilder(
      stream: FavorieService()
          .collection
          .where('idModele', isEqualTo: modeleId)
          .where('idUtilisateur', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        final isSaved = snapshot.data?.docs.isNotEmpty ?? false;
        return _SaveIconButton(
          isSaved: isSaved,
          onPressed: () async {
            HapticFeedback.selectionClick();
            if (isSaved) {
              await FavorieService().removeFavorite(modeleId);
            } else {
              await FavorieService().addFavorite(modeleId);
            }
          },
        );
      },
    );
  }
}

class _SaveIconButton extends StatelessWidget {
  const _SaveIconButton({required this.isSaved, this.onPressed});
  final bool isSaved;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        tooltip: isSaved ? 'home_unsave'.tr : 'home_save'.tr,
        iconSize: 19,
        color: AppColors.white,
        icon: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
      ),
    );
  }
}
