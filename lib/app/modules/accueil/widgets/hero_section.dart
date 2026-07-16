import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/engagement_tracking_service.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import '../../../style/app_colors.dart';

/// Immersive fullscreen hero section for the home page.
///
/// Shows a premium highlight model with editorial typography and CTAs.
class HeroSection extends StatefulWidget {
  final List<Modele> modeles;
  final ValueChanged<Modele>? onModelOpened;
  const HeroSection({
    super.key,
    required this.modeles,
    this.onModelOpened,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final first = widget.modeles.isNotEmpty ? widget.modeles.first : null;
      if (first?.id != null) {
        EngagementTrackingService.instance.trackImpression(
          first!.id!,
          source: 'hero_carousel',
          categoryId: first.idCategorie,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modeles.length != widget.modeles.length) {
      _currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.modeles.isEmpty) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.sizeOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.modeles.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
            final modele = widget.modeles[index];
            if (modele.id != null) {
              EngagementTrackingService.instance.trackImpression(
                modele.id!,
                source: 'hero_carousel',
                categoryId: modele.idCategorie,
              );
            }
          },
          itemBuilder: (context, index) {
            final modele = widget.modeles[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: _HeroMediaBackground(
                    mediaUrl:
                        modele.fichier.isNotEmpty ? modele.fichier[0]! : '',
                    autoplay: _currentIndex == index,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.55,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                          const Color(0xFF1A1A1A).withValues(alpha: 0.9),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: AppSpacing.huge,
                  left: AppSpacing.xxl,
                  right: AppSpacing.xxl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        modele.genreHabit.toUpperCase(),
                        style: AppTypography.labelMedium.copyWith(
                          color: const Color(0xFFE0D5C8),
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (modele.detail != null && modele.detail!.isNotEmpty)
                        Text(
                          modele.detail!,
                          style: AppTypography.displayMedium.copyWith(
                            color: const Color(0xFFF5F0EB),
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      _HeroCta(
                        label: 'home_view_model'.tr,
                        filled: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (modele.id != null) {
                            EngagementTrackingService.instance.trackOpen(
                              modele.id!,
                              source: 'hero_cta',
                              categoryId: modele.idCategorie,
                            );
                          }
                          widget.onModelOpened?.call(modele);
                          Get.to(
                            () => DetailModeleView(modele),
                            transition: Transition.rightToLeft,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        if (widget.modeles.length > 1)
          Positioned(
            bottom: AppSpacing.lg,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.modeles.length, (index) {
                final isActive = _currentIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.white.withValues(alpha: 0.95)
                        : AppColors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _HeroMediaBackground extends StatefulWidget {
  const _HeroMediaBackground({
    required this.mediaUrl,
    required this.autoplay,
  });

  final String mediaUrl;
  final bool autoplay;

  @override
  State<_HeroMediaBackground> createState() => _HeroMediaBackgroundState();
}

class _HeroMediaBackgroundState extends State<_HeroMediaBackground> {
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideo;

  bool get _isVideo {
    final lower = widget.mediaUrl.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('video');
  }

  @override
  void initState() {
    super.initState();
    _initVideoIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _HeroMediaBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mediaUrl != widget.mediaUrl) {
      _disposeVideo();
      _initVideoIfNeeded();
      return;
    }

    if (_videoController != null) {
      if (widget.autoplay) {
        _videoController!.play();
      } else {
        _videoController!.pause();
      }
    }
  }

  void _initVideoIfNeeded() {
    if (!_isVideo || widget.mediaUrl.isEmpty) return;

    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
    _videoController = controller;
    _initializeVideo = controller.initialize().then((_) async {
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (widget.autoplay) {
        await controller.play();
      }
      if (mounted) setState(() {});
    });
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    _initializeVideo = null;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo && _videoController != null) {
      return FutureBuilder<void>(
        future: _initializeVideo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _videoController!.value.isInitialized) {
            return FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            );
          }

          return Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Container(color: AppColors.shimmerBase),
          );
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.mediaUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 600),
      fadeInCurve: Curves.easeIn,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(color: AppColors.shimmerBase),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.backgroundDark,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: AppColors.grey600, size: 48),
        ),
      ),
    );
  }
}

/// Minimal CTA button for the hero section.
class _HeroCta extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _HeroCta({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_HeroCta> createState() => _HeroCtaState();
}

class _HeroCtaState extends State<_HeroCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: widget.filled
                ? const Color(0xFFF5F0EB).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFF5F0EB).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: const Color(0xFFF5F0EB),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
