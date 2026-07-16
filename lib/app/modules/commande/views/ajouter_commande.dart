import 'dart:io';

import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/mesure_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/widgets/mesure_popup.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AjoutCommandePage extends StatefulWidget {
  const AjoutCommandePage(this.modele, {this.tailleur, super.key});

  final Modele modele;
  final UserModel? tailleur;

  @override
  State<AjoutCommandePage> createState() => _AjoutCommandePageState();
}

class _AjoutCommandePageState extends State<AjoutCommandePage> {
  late final CommandeController _controller;
  final MesureService _mesureService = MesureService();

  bool get _isTailleur => _controller.userController.isTailleur.value;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<CommandeController>()
        ? Get.find<CommandeController>()
        : Get.put(CommandeController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.prepareOrderForm(widget.modele, tailleur: widget.tailleur);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    _controller.image.value = image;
    await _controller.saveOrderDraft(widget.modele, tailleur: widget.tailleur);
  }

  Future<void> _selectMesure() async {
    var userId = _controller.userController.currentUser.value.id;
    if (userId == null || userId.isEmpty) {
      await _controller.userController.init();
      userId = _controller.userController.currentUser.value.id;
    }
    userId ??= auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      showCustomSnackbar(message: 'Reconnectez-vous pour charger les mesures.');
      return;
    }

    final mesures = await _mesureService.getAllUserMesure(userId).first;
    if (!mounted) return;
    if (mesures.isEmpty) {
      showCustomSnackbar(message: 'Aucune mesure disponible pour ce compte.');
      return;
    }
    mesuresPopUp(
      context: context,
      mesures: mesures,
      onMesureSelected: (Mesure mesure) async {
        _controller.mesure.value = mesure;
        await _controller.saveOrderDraft(widget.modele,
            tailleur: widget.tailleur);
      },
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (date == null) return;
    _controller.selectedDate.value = DateFormat('yyyy-MM-dd').format(date);
    await _controller.saveOrderDraft(widget.modele, tailleur: widget.tailleur);
  }

  Future<void> _continue() async {
    final step = _controller.orderFormStep.value;
    if (step == 0 && _controller.image.value == null) {
      showCustomSnackbar(message: 'Ajoutez une photo de l\'habit à réaliser.');
      return;
    }
    if (step == 1) {
      if (_isTailleur &&
          (_controller.nomController.text.trim().isEmpty ||
              int.tryParse(_controller.numeroController.text.trim()) == null)) {
        showCustomSnackbar(
            message: 'Renseignez le nom et le numéro du client.');
        return;
      }
      if (_controller.mesure.value == null ||
          _controller.selectedDate.value.isEmpty) {
        showCustomSnackbar(
            message: 'Choisissez les mesures et la date prévue.');
        return;
      }
    }
    await _controller.saveOrderDraft(widget.modele, tailleur: widget.tailleur);
    _controller.orderFormStep.value = step + 1;
  }

  Future<void> _saveDraftSilently() async {
    await _controller.saveOrderDraft(widget.modele, tailleur: widget.tailleur);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _saveDraftSilently();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nouvelle commande'),
          actions: [
            Tooltip(
              message: 'Enregistrer le brouillon',
              child: IconButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await _controller.saveOrderDraft(
                    widget.modele,
                    tailleur: widget.tailleur,
                  );
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Brouillon enregistré.')),
                    );
                  }
                },
                icon: const Icon(Icons.save_outlined),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (_controller.isDraftLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stepper(
            currentStep: _controller.orderFormStep.value,
            type: StepperType.horizontal,
            onStepTapped: (step) {
              if (step <= _controller.orderFormStep.value) {
                _controller.orderFormStep.value = step;
              }
            },
            controlsBuilder: (context, details) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Row(
                children: [
                  if (_controller.orderFormStep.value > 0)
                    IconButton(
                      tooltip: 'Étape précédente',
                      onPressed: () => _controller.orderFormStep.value--,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  const Spacer(),
                  if (_controller.orderFormStep.value < 2)
                    FilledButton.icon(
                      onPressed: _continue,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continuer'),
                    )
                  else
                    Obx(
                      () => FilledButton.icon(
                        onPressed: _controller.isSending.value
                            ? null
                            : () => _controller.createCommande(
                                  widget.modele,
                                  tailleur: widget.tailleur,
                                ),
                        icon: _controller.isSending.value
                            ? circularProgress()
                            : const Icon(Icons.send_outlined),
                        label: Text(_isTailleur ? 'Enregistrer' : 'Envoyer'),
                      ),
                    ),
                ],
              ),
            ),
            steps: [
              Step(
                title: const Text('Habit'),
                isActive: _controller.orderFormStep.value >= 0,
                content: _PhotoStep(
                  image: _controller.image.value,
                  onCamera: () => _pickImage(ImageSource.camera),
                  onGallery: () => _pickImage(ImageSource.gallery),
                ),
              ),
              Step(
                title: const Text('Détails'),
                isActive: _controller.orderFormStep.value >= 1,
                content: _DetailsStep(
                  controller: _controller,
                  isTailleur: _isTailleur,
                  onSelectMesure: _selectMesure,
                  onSelectDate: _selectDate,
                ),
              ),
              Step(
                title: const Text('Vérifier'),
                isActive: _controller.orderFormStep.value >= 2,
                content: _ReviewStep(
                  controller: _controller,
                  modele: widget.modele,
                  isTailleur: _isTailleur,
                  colorScheme: theme.colorScheme,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PhotoStep extends StatelessWidget {
  const _PhotoStep({
    required this.image,
    required this.onCamera,
    required this.onGallery,
  });

  final XFile? image;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photo de l\'habit', style: AppTypography.titleMedium),
        AppSpacing.gapV4,
        Text(
          'Ajoutez une référence claire de la coupe ou du tissu à réaliser.',
          style: AppTypography.bodySmall,
        ),
        AppSpacing.gapV16,
        AspectRatio(
          aspectRatio: 4 / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: image == null
                ? const Center(
                    child: Icon(Icons.add_a_photo_outlined, size: 48))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 48),
                      ),
                    ),
                  ),
          ),
        ),
        AppSpacing.gapV8,
        Row(
          children: [
            IconButton(
              tooltip: 'Prendre une photo',
              onPressed: onCamera,
              icon: const Icon(Icons.camera_alt_outlined),
            ),
            IconButton(
              tooltip: 'Choisir dans la galerie',
              onPressed: onGallery,
              icon: const Icon(Icons.photo_library_outlined),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.controller,
    required this.isTailleur,
    required this.onSelectMesure,
    required this.onSelectDate,
  });

  final CommandeController controller;
  final bool isTailleur;
  final VoidCallback onSelectMesure;
  final VoidCallback onSelectDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isTailleur) ...[
          TextField(
            controller: controller.nomController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nom du client'),
          ),
          AppSpacing.gapV12,
          TextField(
            controller: controller.numeroController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Numéro du client'),
          ),
          AppSpacing.gapV12,
        ],
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.straighten_outlined),
          title: const Text('Mesures'),
          subtitle: Obx(() => Text(
                controller.mesure.value?.nom ?? 'Choisir une fiche de mesures',
              )),
          trailing: const Icon(Icons.chevron_right),
          onTap: onSelectMesure,
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: const Text('Date prévue'),
          subtitle: Obx(() => Text(
                controller.selectedDate.value.isEmpty
                    ? 'Choisir une date'
                    : DateFormat('d MMMM yyyy', 'fr_FR')
                        .format(DateTime.parse(controller.selectedDate.value)),
              )),
          trailing: const Icon(Icons.chevron_right),
          onTap: onSelectDate,
        ),
        if (isTailleur) ...[
          AppSpacing.gapV12,
          TextField(
            controller: controller.prixController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Prix convenu (FCFA)'),
          ),
        ],
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.controller,
    required this.modele,
    required this.isTailleur,
    required this.colorScheme,
  });

  final CommandeController controller;
  final Modele modele;
  final bool isTailleur;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (
        Icons.checkroom_outlined,
        'Modèle',
        modele.detail ?? 'Modèle sélectionné'
      ),
      (
        Icons.straighten_outlined,
        'Mesures',
        controller.mesure.value?.nom ?? '-'
      ),
      (Icons.event_outlined, 'Date prévue', controller.selectedDate.value),
      if (isTailleur)
        (Icons.person_outline, 'Client', controller.nomController.text.trim()),
      if (isTailleur)
        (
          Icons.payments_outlined,
          'Prix',
          '${controller.prixController.text.trim()} FCFA'
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vérifiez avant l\'envoi', style: AppTypography.titleMedium),
        AppSpacing.gapV8,
        ...rows.map(
          (row) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(row.$1, color: colorScheme.primary),
            title: Text(row.$2),
            subtitle: Text(row.$3.isEmpty ? '-' : row.$3),
          ),
        ),
      ],
    );
  }
}
