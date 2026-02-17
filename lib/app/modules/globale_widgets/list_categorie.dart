import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
import 'package:faani/app/style/app_animations.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Enhanced category filter optimized for TikTok-style home page with African clothing models.
///
/// Features:
/// - Semi-transparent overlay to avoid interfering with model images
/// - Compact design for minimal content obstruction
/// - Smooth animations and micro-interactions
/// - Smart positioning for vertical video feed
/// - Performance optimized with const constructors
/// - Touch-friendly for mobile swipe interactions
class CategorieFiltre<T extends GetxController> extends StatefulWidget {
  final T controller;
  final bool isOverlay; // For home page overlay mode
  final VoidCallback? onExpand; // For expand/collapse functionality
  const CategorieFiltre({
    super.key,
    required this.controller,
    this.isOverlay = false,
    this.onExpand,
  });

  @override
  State<CategorieFiltre<T>> createState() => _CategorieFiltreState<T>();
}

class _CategorieFiltreState<T extends GetxController>
    extends State<CategorieFiltre<T>> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final RxList<Categorie> _categories = <Categorie>[].obs;
  bool _isLoading = true;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fetchCategories();
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _fetchCategories() {
    CategorieService().getCategorie().listen(
      (categories) {
        _categories.value = categories;
        _isLoading = false;
      },
      onError: (error) {
        _isLoading = false;
      },
    );
  }

  void _scrollToCenter(int selectedIndex) {
    if (!_scrollController.hasClients) return;

    // Calculate item width with padding
    const itemWidth = 100.0; // Optimized for mobile
    final screenWidth = MediaQuery.sizeOf(context).width;
    final targetOffset =
        selectedIndex * itemWidth - (screenWidth / 2 - itemWidth / 2);

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScrollExtent);

    _scrollController.animateTo(
      clampedOffset,
      duration: AppAnimations.normal,
      curve: Curves.easeOutCubic,
    );
  }

  void _onCategorySelected(Categorie categorie, int index) {
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    setState(() {
      // Single selection mode - clear others
      for (var cat in _categories) {
        cat.isSelected = false;
      }
      categorie.isSelected = true;
    });

    // Scroll to center with smooth animation
    _scrollToCenter(index);

    // Notify parent controller
    (widget.controller as dynamic).onCategorieSelected(categorie);

    // Auto-collapse on selection in overlay mode
    if (widget.isOverlay && _isExpanded) {
      _toggleExpanded();
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpand?.call();
  }

  Widget _buildCategoryChip(Categorie categorie, int index) {
    final isSelected = categorie.isSelected;
    final isOverlayMode = widget.isOverlay;

    return AnimatedContainer(
      duration: AppAnimations.fast,
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      child: Material(
        color: isSelected
            ? (isOverlayMode
                ? AppColors.primary.withValues(alpha: 0.9)
                : AppColors.primary)
            : (isOverlayMode
                ? AppColors.black.withValues(alpha: 0.3)
                : AppColors.surfaceLight),
        borderRadius: AppRadius.radiusFull,
        elevation: isSelected ? (isOverlayMode ? 1 : 2) : 0,
        child: InkWell(
          onTap: () => _onCategorySelected(categorie, index),
          borderRadius: AppRadius.radiusFull,
          splashColor: isOverlayMode
              ? AppColors.white.withValues(alpha: 0.2)
              : AppColors.primaryLight,
          highlightColor: isOverlayMode
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.primaryLight.withValues(alpha: 0.1),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isOverlayMode ? AppSpacing.sm : AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: AnimatedDefaultTextStyle(
              duration: AppAnimations.fast,
              style: isSelected
                  ? AppTypography.labelSmall.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    )
                  : AppTypography.labelSmall.copyWith(
                      color: isOverlayMode
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              child: Text(
                categorie.libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: widget.isOverlay
              ? AppColors.black.withValues(alpha: 0.3)
              : AppColors.surfaceLight,
          borderRadius: AppRadius.radiusFull,
        ),
        child: Icon(
          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 16,
          color: widget.isOverlay ? AppColors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: widget.isOverlay ? 36 : 50,
      child: Row(
        children: List.generate(3, (index) => _buildShimmerChip()),
      ),
    );
  }

  Widget _buildShimmerChip() {
    return Container(
      width: widget.isOverlay ? 60 : 80,
      height: widget.isOverlay ? 24 : 32,
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      decoration: BoxDecoration(
        color: widget.isOverlay
            ? AppColors.white.withValues(alpha: 0.2)
            : AppColors.grey200,
        borderRadius: AppRadius.radiusFull,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.isOverlay ? 36 : 50,
      alignment: Alignment.center,
      child: Text(
        'Aucune catégorie',
        style: AppTypography.bodySmall.copyWith(
          color: widget.isOverlay
              ? AppColors.white.withValues(alpha: 0.7)
              : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isOverlay ? AppSpacing.sm : AppSpacing.md,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryChip(_categories[index], index);
      },
    );
  }

  Widget _buildOverlayContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(_slideAnimation),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.6),
                    AppColors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with expand button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '🏷️ Filtrer',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          _buildExpandButton(),
                        ],
                      ),
                    ),
                    // Category chips
                    if (_isExpanded) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _buildCategoryList(),
                    ],
                    // Compact mode indicator
                    if (!_isExpanded)
                      Container(
                        height: 4,
                        width: 40,
                        margin:
                            const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.4),
                          borderRadius: AppRadius.radiusFull,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegularContent() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey200,
            width: 0.5,
          ),
        ),
      ),
      child: _buildCategoryList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_isLoading) {
        return _buildLoadingState();
      }

      if (_categories.isEmpty) {
        return _buildEmptyState();
      }

      return widget.isOverlay ? _buildOverlayContent() : _buildRegularContent();
    });
  }
}
