import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DisplayImage extends StatelessWidget {
  final Modele modele;
  const DisplayImage({super.key, required this.modele});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Stack(
      children: [
        PageView(
          controller: controller,
          children: [
            for (var image in modele.fichier)
              ClipRRect(
                borderRadius: AppRadius.bottomLg,
                child: CachedNetworkImage(
                  imageUrl: image!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          bottom: AppSpacing.md,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: controller,
              count: modele.fichier.length,
              effect: const ExpandingDotsEffect(
                dotColor: AppColors.grey400,
                activeDotColor: AppColors.primary,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 4,
              ),
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.xl,
          left: AppSpacing.sm,
          child: shadowBackButton(context),
        ),
      ],
    );
  }
}

Widget shadowBackButton(BuildContext context) {
  return Material(
    color: AppColors.overlay,
    shape: const CircleBorder(),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.pop(context),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Icon(
          Icons.arrow_back,
          color: AppColors.white,
          size: 20,
        ),
      ),
    ),
  );
}

Widget imageCacheNetwork(BuildContext context, String url) {
  return CachedNetworkImage(
    imageUrl: url,
    placeholder: (context, url) => shimmer(),
    imageBuilder: (context, imageProvider) => DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    errorWidget: (context, url, error) => const Icon(
      Icons.error_outline,
      color: AppColors.primary,
    ),
  );
}
