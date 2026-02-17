import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/app_button.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../routes/app_pages.dart';
import '../../globale_widgets/circular_progress.dart';
import '../controllers/authentification_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUser = auth.currentUser != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: hasUser
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasUser) AppSpacing.gapV24,

              // ── Brand title ──────────────────────────────────────
              Text(
                'Faani',
                textAlign: TextAlign.center,
                style: AppTypography.brandTitle.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              AppSpacing.gapV12,

              // ── Tagline ──────────────────────────────────────────
              Text(
                'Explorer des milliers de modèles\nPrendre vos mesures en un clic',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapV16,

              // ── Hero image ───────────────────────────────────────
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: Image.asset(
                  'assets/images/welcome_img.png',
                  fit: BoxFit.contain,
                ),
              ),
              AppSpacing.gapV32,

              // ── Phone input ──────────────────────────────────────
              IntlPhoneField(
                cursorColor: theme.colorScheme.primary,
                invalidNumberMessage: 'Numéro invalide',
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                ),
                initialCountryCode: 'ML',
                onChanged: (phone) {
                  controller.phoneNumber.value = phone.completeNumber;
                },
              ),
              AppSpacing.gapV16,

              // ── SMS button ───────────────────────────────────────
              Obx(() => AppButton(
                    label: 'Recevoir le code SMS',
                    isLoading: controller.loading.value,
                    isExpanded: true,
                    onPressed: () {
                      final phone = controller.phoneNumber.value.trim();
                      if (phone.isEmpty || !phone.startsWith('+')) {
                        showCustomSnackbar(
                          message: 'Entrez un numéro valide (ex: +223xxxxxxxx)',
                          backgroundColor: AppColors.error,
                        );
                        return;
                      }
                      controller.verifyPhoneNumber(phone);
                    },
                  )),
              AppSpacing.gapV24,

              // ── Divider ──────────────────────────────────────────
              _OrDivider(theme: theme),
              AppSpacing.gapV24,

              // ── Google sign-in ────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () => controller.signInWithGoogle(),
                icon: Image.asset(
                  'assets/images/google_auth.png',
                  width: 24,
                  height: 24,
                ),
                label: const Text('S\'identifier avec Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              AppSpacing.gapV16,

              // ── Anonymous sign-in ─────────────────────────────────
              if (!hasUser)
                Obx(() => AppButton(
                      label: 'Continuer sans compte',
                      variant: AppButtonVariant.outline,
                      isLoading: controller.isLoading.value,
                      isExpanded: true,
                      onPressed: () async {
                        controller.isLoading.value = true;
                        final anonyme = await controller.signInAnonymously();
                        if (anonyme != null) {
                          Get.offAllNamed(Routes.HOME);
                        }
                      },
                    )),
              AppSpacing.gapV24,
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal "Ou" divider extracted for readability.
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final dividerColor = theme.colorScheme.outlineVariant;
    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor)),
        Padding(
          padding: AppSpacing.paddingHLg,
          child: Text(
            'Ou',
            style: AppTypography.labelLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: dividerColor)),
      ],
    );
  }
}
