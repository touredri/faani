# Résorber la dette d'analyse statique historique

> **Statut** : done  
> **Priorité** : moyenne  
> **Créé le** : 2026-07-11

## Contexte

L'audit architectural 001 a réduit la baseline globale de 126 à 120 alertes sans désactiver de règle. Aucune erreur de compilation ne subsiste; les alertes concernent principalement du code historique non modifié par les phases architecturales.

## Plan

- [x] Remplacer les `print` de production par `debugPrint`.
- [x] Migrer les `withOpacity` vers `withValues`.
- [x] Corriger les usages de `BuildContext` après des opérations asynchrones.
- [x] Renommer les champs legacy tout en conservant les clés de sérialisation Firestore.
- [x] Corriger les types privés exposés par les APIs publiques.
- [x] Remplacer l'API audio expérimentale par `AudioSource.uri`.
- [x] Exclure uniquement `lib/generated/**`, sans désactiver les règles globales.
- [x] Obtenir `flutter analyze` sans alertes.

## Critères de validation

- [x] `rtk flutter analyze` termine sans erreur ni alerte.
- [x] `rtk flutter test` reste vert avec 24 tests.
- [x] Les clés Firestore/JSON snake_case sont conservées.
