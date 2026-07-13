# Mesures guidées par caméra

> **Statut** : phase 1 terminée, phase 2 planifiée  
> **Priorité** : haute  
> **Créé le** : 2026-07-11

## Contexte

Le bouton « Par caméra » dans `AjoutMesure` affichait un placeholder. La phase 1 a livré un parcours local qui estime prudemment l'épaule et la longueur de pantalon, puis complète les six circonférences manuellement avant sauvegarde.

La phase 2 étend ce parcours à l'estimation locale des circonférences, sans stockage ni transfert d'images. La décision est documentée dans `docs/adr/002-estimation-de-circonference-locale.md`.

## Objectif

Parcours complet : saisie de taille, captures guidées face et profil, estimation on-device, révision et sauvegarde Firestore. Les circonférences ne sont préremplies que lorsque la qualité de capture et la précision du modèle sont validées.

## Périmètre

### Inclus
- ML Kit pose detection on-device
- Calibration par taille saisie + cadrage dans la silhouette
- Automatisation de `epaule` et `longueur`
- Saisie manuelle de `bras`, `hanche`, `poitrine`, `taille`, `ventre`, `poignet` en repli
- Repository injectable pour la sauvegarde
- Tests unitaires estimateur et machine d'états

### Exclus
- Stockage ou envoi des images
- Sécurisation Firestore globale du catch-all `mesure`

## Plan d'implémentation

- [x] Dépendances ML Kit et préparation plateformes
- [x] Domaine : brouillon, estimateur, machine d'états
- [x] UI caméra et guidage silhouette
- [x] Parcours manuel partiel + révision + repository
- [x] Localisation et gestion erreurs/permissions
- [x] Tests et validation
- [x] Phase 2 : protocole local face/profil et calibration par taille saisie
- [ ] Phase 2 : repère physique de calibration et validation de son impact
- [x] Phase 2 : modèle de contour et estimateur des six circonférences
- [ ] Phase 2 : jeu de validation comparé au mètre ruban et seuils d'acceptation
- [x] Phase 2 : préremplissage conditionnel et repli manuel par champ

## Fichiers concernés

- `lib/app/domain/mesures/`
- `lib/app/data/services/body_pose_detection_service.dart`
- `lib/app/data/repositories/firestore_mesure_repository.dart`
- `lib/app/modules/mesures/controllers/camera_mesure_controller.dart`
- `lib/app/modules/mesures/views/camera_mesure_view.dart`
- `lib/app/modules/mesures/views/ajouter_mesure.dart`
- `pubspec.yaml`, `ios/Podfile`, `firestore.rules` (note sécurité)

## Critères de validation

- [x] Parcours caméra fonctionnel sur Android et iOS
- [x] Épaule et longueur préremplies quand confiance suffisante
- [x] Six champs manuels + révision avant sauvegarde
- [x] Tests estimateur et machine d'états verts
- [x] `rtk flutter analyze` ciblé sans erreur
