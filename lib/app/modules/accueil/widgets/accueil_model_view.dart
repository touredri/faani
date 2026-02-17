import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/globale_widgets/list_tailleur_bottom_sheet.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:faani/src/comment_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../globale_widgets/favorite_icon.dart';
import '../controllers/accueil_controller.dart';

class HomeItem extends StatefulWidget {
  final Modele modele;
  const HomeItem(this.modele, {super.key});

  @override
  State<HomeItem> createState() => _HomeItemState();
}

class _HomeItemState extends State<HomeItem>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final AccueilController controller = Get.find<AccueilController>();
  late final AnimationController _doubleTapController;
  late final Animation<double> _doubleTapScale;
  bool _showHeart = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _doubleTapController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _doubleTapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_doubleTapController);
  }

  @override
  void dispose() {
    _doubleTapController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    setState(() => _showHeart = true);
    _doubleTapController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.sizeOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Full-bleed image ───────────────────────────────────────
        Positioned.fill(
          child: GestureDetector(
            onDoubleTap: _onDoubleTap,
            child: CachedNetworkImage(
              imageUrl: widget.modele.fichier[0]!,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 400),
              fadeInCurve: Curves.easeIn,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: const Color(0xFF2A2A2A),
                highlightColor: const Color(0xFF3A3A3A),
                child: Container(color: const Color(0xFF2A2A2A)),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF1A1A1A),
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: AppColors.grey600, size: 40),
                ),
              ),
            ),
          ),
        ),

        // ── Bottom gradient overlay ────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: size.height * 0.35,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),

        // ── Bottom info overlay ───────────────────────────────────
        Positioned(
          bottom: AppSpacing.huge,
          left: AppSpacing.lg,
          right: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.modele.detail != null &&
                  widget.modele.detail!.isNotEmpty)
                Text(
                  widget.modele.detail!,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    shadows: const [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 6),
              Text(
                widget.modele.genreHabit,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),

        // ── Right action bar ──────────────────────────────────────
        Positioned(
          right: AppSpacing.sm,
          bottom: AppSpacing.huge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: controller.sewingIcon,
                onTap: () {
                  HapticFeedback.lightImpact();
                  final userController = Get.find<UserController>();
                  if (userController.isTailleur.value) {
                    Get.to(() => AjoutCommandePage(widget.modele),
                        transition: Transition.rightToLeft);
                  } else {
                    showTailleurModalBottomSheet(context, widget.modele);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              FavoriteIcone(docId: widget.modele.id!),
              const SizedBox(height: AppSpacing.lg),
              LikeIcon(docId: widget.modele.id!),
              const SizedBox(height: AppSpacing.lg),
              _CommentButton(modele: widget.modele),
              const SizedBox(height: AppSpacing.lg),
              _ActionButton(
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => DetailModeleView(widget.modele),
                      transition: Transition.rightToLeft);
                },
              ),
            ],
          ),
        ),

        // ── Double-tap heart animation ────────────────────────────
        if (_showHeart)
          Center(
            child: AnimatedBuilder(
              animation: _doubleTapScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _doubleTapScale.value,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary.withValues(alpha: 0.85),
                    size: 100,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Minimal action button wrapper for consistent sizing
class _ActionButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(child: icon),
      ),
    );
  }
}

/// Comment button with live count
class _CommentButton extends StatelessWidget {
  final Modele modele;
  const _CommentButton({required this.modele});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            showModalBottomSheet(
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: const Color.fromARGB(150, 145, 144, 144),
              context: context,
              builder: (context) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.80,
                  child: CommentModal(idModele: modele.id!),
                );
              },
            );
          },
          child: const Icon(
            Icons.message_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 2),
        StreamBuilder<int>(
          stream: ModeleService().getCommentCount(modele.id!),
          builder: (context, snapshot) {
            return Text(
              snapshot.hasData ? '${snapshot.data}' : '0',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            );
          },
        ),
      ],
    );
  }
}
