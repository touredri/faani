import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/tailleur_request.dart';
import 'package:faani/app/data/models/tailor_review.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/follow.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/tailleur_request_service.dart';
import 'package:faani/app/data/services/tailor_review_service.dart';
import 'package:faani/app/domain/profile/tailor_availability.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/message/controllers/message_controller.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TailorProfilePage extends StatefulWidget {
  const TailorProfilePage({super.key, required this.tailor});

  final UserModel tailor;

  @override
  State<TailorProfilePage> createState() => _TailorProfilePageState();
}

class _TailorProfilePageState extends State<TailorProfilePage> {
  late final Future<_TailorProfileData> _profileFuture;
  final FollowService _followService = FollowService();

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<_TailorProfileData> _loadProfile() async {
    final tailorId = widget.tailor.id;
    if (tailorId == null || tailorId.isEmpty) {
      return const _TailorProfileData();
    }
    final results = await Future.wait<dynamic>([
      ModeleService().getDiscoverableByTailleur(tailorId, limit: 60),
      ModeleService().getTotalModeleCount(tailorId),
      TailleurRequestService().getRequestByUserId(tailorId),
    ]);
    return _TailorProfileData(
      models: results[0] as List<Modele>,
      totalModels: results[1] as int,
      workshop: results[2] as TailleurRequest?,
    );
  }

  void _openConversation() {
    if (auth.currentUser?.uid == widget.tailor.id) return;
    final messageController = Get.isRegistered<MessageController>()
        ? Get.find<MessageController>()
        : Get.put(MessageController());
    messageController.goChat(widget.tailor, modeleImg: '');
  }

  Future<void> _toggleFollow(bool isFollowing) async {
    final currentUserId = auth.currentUser?.uid;
    final tailorId = widget.tailor.id;
    if (currentUserId == null ||
        tailorId == null ||
        currentUserId == tailorId) {
      return;
    }
    try {
      await _followService.updateFollowStatus(
          currentUserId, tailorId, !isFollowing);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Impossible de mettre à jour l\'abonnement.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tailorId = widget.tailor.id;
    final isOwnProfile = auth.currentUser?.uid == tailorId;
    return Scaffold(
      body: FutureBuilder<_TailorProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final data = snapshot.data ?? const _TailorProfileData();
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 290,
                title: const Text('Atelier'),
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProfileHero(
                    tailor: widget.tailor,
                    workshop: data.workshop,
                    onMessage: isOwnProfile ? null : _openConversation,
                    onFollow: isOwnProfile || tailorId == null
                        ? null
                        : () => _FollowButton(
                              followService: _followService,
                              currentUserId: auth.currentUser?.uid,
                              tailleurId: tailorId,
                              onToggle: _toggleFollow,
                            ),
                  ),
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ServiceSummary(
                          totalModels: data.totalModels,
                          tailorId: tailorId,
                          workshop: data.workshop,
                        ),
                        AppSpacing.gapV24,
                        Text('L\'atelier', style: AppTypography.titleMedium),
                        AppSpacing.gapV8,
                        _WorkshopDetails(
                          tailor: widget.tailor,
                          workshop: data.workshop,
                        ),
                        AppSpacing.gapV24,
                        if (widget.tailor.tailorBio.trim().isNotEmpty) ...[
                          Text('Présentation',
                              style: AppTypography.titleMedium),
                          AppSpacing.gapV8,
                          Text(
                            widget.tailor.tailorBio,
                            style: AppTypography.bodyMedium.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.gapV24,
                        ],
                        _ReviewsSection(tailor: widget.tailor),
                        AppSpacing.gapV24,
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Modèles publiés',
                                style: AppTypography.titleMedium,
                              ),
                            ),
                            Text(
                              '${data.totalModels}',
                              style: AppTypography.labelLarge.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapV12,
                      ],
                    ),
                  ),
                ),
                if (data.models.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: AppSpacing.pageHorizontal,
                      child:
                          Text('Cet atelier n\'a pas encore publié de modèle.'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.massive,
                    ),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: data.models.length,
                      itemBuilder: (context, index) => _PortfolioTile(
                        modele: data.models[index],
                        onTap: () => Get.to(
                          () => DetailModeleView(data.models[index]),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TailorProfileData {
  const _TailorProfileData({
    this.models = const [],
    this.totalModels = 0,
    this.workshop,
  });

  final List<Modele> models;
  final int totalModels;
  final TailleurRequest? workshop;
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.tailor,
    required this.workshop,
    required this.onMessage,
    required this.onFollow,
  });

  final UserModel tailor;
  final TailleurRequest? workshop;
  final VoidCallback? onMessage;
  final Widget Function()? onFollow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workshopName = workshop?.nomAtelier.trim();
    final displayName = workshopName?.isNotEmpty == true
        ? workshopName!
        : (tailor.nomPrenom ?? 'Atelier');
    final avatarUrl = tailor.profileImage;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          80,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Icon(
                          Icons.storefront_outlined,
                          color: theme.colorScheme.primary,
                          size: 34,
                        )
                      : null,
                ),
                AppSpacing.gapH12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: AppTypography.headlineSmall),
                      AppSpacing.gapV4,
                      Text(
                        tailor.clientCible?.trim().isNotEmpty == true
                            ? tailor.clientCible!
                            : 'Confection générale',
                        style: AppTypography.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.gapV4,
                      _AvailabilityChip(
                          availability: tailor.tailorAvailability),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.gapV12,
            if (workshop?.isApproved == true)
              _VerifiedChip(colorScheme: theme.colorScheme),
            const Spacer(),
            Row(
              children: [
                if (onFollow != null) onFollow!(),
                if (onFollow != null) AppSpacing.gapH8,
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onMessage,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Écrire'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 16, color: colorScheme.primary),
          AppSpacing.gapH4,
          Text('Atelier approuvé', style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.availability});
  final TailorAvailability availability;

  @override
  Widget build(BuildContext context) {
    final color = switch (availability) {
      TailorAvailability.available => AppColors.success,
      TailorAvailability.limited => AppColors.warning,
      TailorAvailability.unavailable => AppColors.grey600,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        availability.label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.followService,
    required this.currentUserId,
    required this.tailleurId,
    required this.onToggle,
  });

  final FollowService followService;
  final String? currentUserId;
  final String tailleurId;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) return const SizedBox.shrink();
    return StreamBuilder<List<String>>(
      stream: followService.getFollowing(currentUserId!),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data?.contains(tailleurId) ?? false;
        return OutlinedButton(
          onPressed: () => onToggle(isFollowing),
          child: Text(isFollowing ? 'Suivi' : 'Suivre'),
        );
      },
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  const _ServiceSummary({
    required this.totalModels,
    required this.tailorId,
    required this.workshop,
  });
  final int totalModels;
  final String? tailorId;
  final TailleurRequest? workshop;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: FollowService().getFollowStats(tailorId ?? ''),
      builder: (context, snapshot) {
        final followers = snapshot.data?['followers'] ?? 0;
        return Row(
          children: [
            _Metric(value: '$totalModels', label: 'Modèles'),
            _Metric(value: '$followers', label: 'Abonnés'),
            _Metric(
              value: '${workshop?.nombreTravailleur ?? 0}',
              label: 'À l\'atelier',
            ),
          ],
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.titleLarge),
          AppSpacing.gapV4,
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _WorkshopDetails extends StatelessWidget {
  const _WorkshopDetails({required this.tailor, required this.workshop});
  final UserModel tailor;
  final TailleurRequest? workshop;

  @override
  Widget build(BuildContext context) {
    final location = workshop == null
        ? tailor.adress?.trim()
        : [workshop!.quartier, workshop!.ville, workshop!.pays]
            .where((item) => item.trim().isNotEmpty)
            .join(', ');
    final rows = [
      (
        Icons.location_on_outlined,
        'Zone',
        location?.isNotEmpty == true ? location! : 'Non renseignée'
      ),
      (
        Icons.style_outlined,
        'Spécialité',
        tailor.tailorSpecialties.isNotEmpty
            ? tailor.tailorSpecialties.join(', ')
            : (workshop?.clientCible.trim().isNotEmpty == true
                ? workshop!.clientCible
                : (tailor.clientCible?.trim().isNotEmpty == true
                    ? tailor.clientCible!
                    : 'Confection générale')),
      ),
      if (workshop != null)
        (
          Icons.groups_outlined,
          'Équipe',
          '${workshop!.nombreTravailleur} personne${workshop!.nombreTravailleur > 1 ? 's' : ''}',
        ),
    ];
    return Column(
      children: rows
          .map(
            (row) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(row.$1),
              title: Text(row.$2),
              trailing: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.46,
                child: Text(
                  row.$3,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ReviewsSection extends StatefulWidget {
  const _ReviewsSection({required this.tailor});
  final UserModel tailor;

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  final TailorReviewService _reviewService = TailorReviewService();

  Future<void> _writeReview() async {
    final reviewerId = auth.currentUser?.uid;
    final tailorId = widget.tailor.id;
    if (reviewerId == null || tailorId == null || reviewerId == tailorId) {
      return;
    }
    final order = await _reviewService.findEligibleOrder(
      tailorId: tailorId,
      reviewerId: reviewerId,
    );
    if (!mounted) return;
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un avis est disponible après une commande terminée.'),
        ),
      );
      return;
    }
    var rating = 5;
    final commentController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Votre avis', style: AppTypography.titleLarge),
              AppSpacing.gapV12,
              DropdownButtonFormField<int>(
                key: ValueKey(rating),
                initialValue: rating,
                decoration: const InputDecoration(labelText: 'Note'),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} / 5'),
                  ),
                ),
                onChanged: (value) => setSheetState(() => rating = value ?? 5),
              ),
              AppSpacing.gapV12,
              TextField(
                controller: commentController,
                maxLength: 500,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Commentaire',
                  hintText: 'Partagez votre expérience',
                ),
              ),
              AppSpacing.gapV12,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await _reviewService.saveReview(
                        tailorId: tailorId,
                        reviewerId: reviewerId,
                        reviewerName: auth.currentUser?.displayName ?? '',
                        orderId: order.id!,
                        rating: rating,
                        comment: commentController.text,
                      );
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    } on FormatException catch (error) {
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text(error.message)),
                        );
                      }
                    }
                  },
                  child: const Text('Publier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tailorId = widget.tailor.id;
    if (tailorId == null) return const SizedBox.shrink();
    final canWrite =
        auth.currentUser?.uid != null && auth.currentUser?.uid != tailorId;
    return StreamBuilder<List<TailorReview>>(
      stream: _reviewService.streamForTailor(tailorId),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <TailorReview>[];
        final average = reviews.isEmpty
            ? null
            : reviews.fold<int>(0, (total, review) => total + review.rating) /
                reviews.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child:
                        Text('Avis clients', style: AppTypography.titleMedium)),
                if (average != null) ...[
                  const Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 18),
                  AppSpacing.gapH4,
                  Text(average.toStringAsFixed(1)),
                ],
              ],
            ),
            if (canWrite)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _writeReview,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Donner mon avis'),
                ),
              ),
            if (reviews.isEmpty)
              Text(
                'Aucun avis pour le moment.',
                style: AppTypography.bodySmall,
              )
            else
              ...reviews.take(3).map(
                    (review) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.account_circle_outlined),
                      title: Text(review.reviewerName),
                      subtitle: Text(
                        review.comment.isEmpty
                            ? 'Avis sans commentaire'
                            : review.comment,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text('${review.rating}/5'),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({required this.modele, required this.onTap});
  final Modele modele;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        modele.fichier.isNotEmpty ? modele.fichier.first ?? '' : '';
    return InkWell(
      borderRadius: AppRadius.radiusSm,
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusSm,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusSm,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.checkroom_outlined),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingAllSm,
                  color: Colors.black.withValues(alpha: 0.56),
                  child: Text(
                    modele.detail ?? 'Modèle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
