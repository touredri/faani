import 'package:faani/app/modules/mesures/controllers/camera_mesure_controller.dart';
import 'package:faani/app/modules/mesures/mesure_strings.dart';
import 'package:faani/app/modules/mesures/views/camera_mesure_view.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CameraMesureIntroView extends StatefulWidget {
  const CameraMesureIntroView({super.key});

  @override
  State<CameraMesureIntroView> createState() => _CameraMesureIntroViewState();
}

class _CameraMesureIntroViewState extends State<CameraMesureIntroView> {
  final _heightController = TextEditingController(text: '170');

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  void _start() {
    final height = int.tryParse(_heightController.text.trim());
    if (height == null || height < 120 || height > 230) {
      Get.snackbar(
        MesureStrings.t('mesures_camera_invalid_height_title',
            fallback: 'Taille invalide'),
        MesureStrings.t(
          'mesures_camera_invalid_height_body',
          fallback: 'Entrez une taille entre 120 et 230 cm.',
        ),
      );
      return;
    }

    Get.to(
      () => const CameraMesureView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CameraMesureController(userHeightCm: height));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MesureStrings.t(
            'mesures_camera_intro_title',
            fallback: 'Mesure par caméra',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              MesureStrings.t(
                'mesures_camera_intro_body',
                fallback:
                    'Nous estimons l\'épaule et la longueur de pantalon à partir de votre silhouette. Les autres mesures seront saisies manuellement.',
              ),
            ),
            3.hs,
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: MesureStrings.t(
                  'mesures_camera_height_label',
                  fallback: 'Votre taille (cm)',
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            2.hs,
            _Tip(
              text: MesureStrings.t(
                'mesures_camera_tip_distance',
                fallback: 'Placez-vous à environ 2 m du téléphone.',
              ),
            ),
            _Tip(
              text: MesureStrings.t(
                'mesures_camera_tip_clothes',
                fallback: 'Portez des vêtements ajustés et un fond dégagé.',
              ),
            ),
            _Tip(
              text: MesureStrings.t(
                'mesures_camera_tip_light',
                fallback: 'Privilégiez une pièce bien éclairée.',
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _start,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                MesureStrings.t(
                  'mesures_camera_start',
                  fallback: 'Commencer',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 18, color: AppColors.primary),
          2.ws,
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
