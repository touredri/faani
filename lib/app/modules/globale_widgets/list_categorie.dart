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
  final RxBool _isLoading = true.obs;
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
        _isLoading.value = false;
      },
      onError: (error) {
        _isLoading.value = false;
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
  }

  Widget _buildCategoryChip(Categorie categorie, int index) {
    final isSelected = categorie.isSelected;
    final isOverlayMode = widget.isOverlay;
    final minChipHeight = isOverlayMode ? 28.0 : 36.0;

    final chipForeground = isSelected
        ? AppColors.white
        : (isOverlayMode
            ? AppColors.white.withValues(alpha: 0.86)
            : AppColors.textSecondary);

    return AnimatedContainer(
      duration: AppAnimations.fast,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.radiusFull,
          onTap: () => _onCategorySelected(categorie, index),
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 0,
            ),
            constraints: BoxConstraints(minHeight: minChipHeight),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isOverlayMode
                      ? AppColors.white.withValues(alpha: 0.16)
                      : AppColors.grey100),
              borderRadius: AppRadius.radiusFull,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryLight.withValues(alpha: 0.45)
                    : (isOverlayMode
                        ? AppColors.white.withValues(alpha: 0.24)
                        : AppColors.grey300),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              categorie.libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              strutStyle: const StrutStyle(
                height: 1.0,
                forceStrutHeight: true,
              ),
              style: AppTypography.labelMedium.copyWith(
                color: chipForeground,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.35,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: widget.isOverlay ? 34 : 50,
      child: Row(
        children: List.generate(3, (index) => _buildShimmerChip()),
      ),
    );
  }

  Widget _buildShimmerChip() {
    return Container(
      width: widget.isOverlay ? 60 : 80,
      height: widget.isOverlay ? 28 : 32,
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
      height: widget.isOverlay ? 34 : 50,
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
      physics: const BouncingScrollPhysics(),
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
            child: SizedBox(
              height: 34,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildCategoryList(),
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
      if (_isLoading.value) {
        return _buildLoadingState();
      }

      if (_categories.isEmpty) {
        return _buildEmptyState();
      }

      return widget.isOverlay ? _buildOverlayContent() : _buildRegularContent();
    });
  }
}
