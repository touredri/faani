import 'package:faani/app/domain/mesures/mesure_draft.dart';
import 'package:faani/app/domain/mesures/mesure_field.dart';
import 'package:faani/app/modules/mesures/controllers/mesures_controller.dart';
import 'package:faani/app/modules/mesures/mesure_strings.dart';
import 'package:faani/app/modules/mesures/views/mesure_review_view.dart';
import 'package:faani/app/modules/mesures/views/widgets/page_view_content.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MesureManualCaptureView extends StatefulWidget {
  const MesureManualCaptureView({super.key, required this.initialDraft});

  final MesureDraft initialDraft;

  @override
  State<MesureManualCaptureView> createState() =>
      _MesureManualCaptureViewState();
}

class _MesureManualCaptureViewState extends State<MesureManualCaptureView> {
  late final MesuresController _controller;
  late final List<MesureField> _fields;
  late final PageController _pageController;
  var _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(MesuresController());
    _controller.applyDraft(widget.initialDraft);
    _fields = [
      ...cameraManualFields,
      ...widget.initialDraft.missingFields().where(cameraAutoFields.contains),
    ];
    _pageController = PageController();
    if (_fields.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Get.off(() => MesureReviewView(draft: widget.initialDraft));
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  TextEditingController _textControllerFor(MesureField field) {
    switch (field) {
      case MesureField.epaule:
        return _controller.epauleController;
      case MesureField.bras:
        return _controller.brasController;
      case MesureField.hanche:
        return _controller.hancheController;
      case MesureField.longueur:
        return _controller.longeurController;
      case MesureField.poitrine:
        return _controller.poitrineController;
      case MesureField.taille:
        return _controller.tailleController;
      case MesureField.ventre:
        return _controller.ventreController;
      case MesureField.poignet:
        return _controller.poignetController;
    }
  }

  void _next() {
    if (_currentPage >= _fields.length - 1) {
      final draft = _controller.buildDraft(widget.initialDraft.userHeightCm);
      Get.to(() => MesureReviewView(draft: draft));
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MesureStrings.t(
            'mesures_manual_title',
            fallback: 'Compléter les mesures',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _fields.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final field = _fields[index];
                return PageViewContent(
                  text: field.label,
                  count: '${index + 1}/${_fields.length}',
                  imagePath: field.imageAsset,
                  controller: _textControllerFor(field),
                );
              },
            ),
          ),
          2.hs,
          TextButton(
            onPressed: _next,
            child: Container(
              height: 40,
              width: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _currentPage >= _fields.length - 1
                    ? MesureStrings.t('mesures_manual_review',
                        fallback: 'Revoir')
                    : MesureStrings.t('mesures_manual_continue',
                        fallback: 'Continuer'),
                style: const TextStyle(color: AppColors.primary, fontSize: 18),
              ),
            ),
          ),
          3.hs,
        ],
      ),
    );
  }
}
