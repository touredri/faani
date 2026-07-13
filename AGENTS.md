# Faani — instructions pour les agents

## Objectif

Faani est une application Flutter/Firebase qui met en relation clients et tailleurs. Les nouvelles fonctionnalités doivent préserver les parcours existants, la sécurité des données et la compatibilité Android/iOS.

## Contexte à charger

- Lire `CONTEXT.md` avant toute modification fonctionnelle.
- Consulter `graphify-out/graph.json` avec `graphify query`, `graphify explain` ou `graphify path` avant de lire de nombreux fichiers.
- Charger uniquement les fichiers directement liés à la tâche. Éviter les lectures globales du dépôt.
- Ne jamais afficher ni copier le contenu des fichiers de secrets ou de signature (`google-services.json`, `GoogleService-Info.plist`, `key.properties`, keystores).

## Commandes et économie de tokens

- Préfixer les commandes shell avec `rtk` (`rtk git status`, `rtk flutter analyze`, etc.).
- Utiliser `rg`/`rg --files` pour les recherches ciblées.
- Après une modification de code, lancer `graphify update` plutôt qu’une reconstruction complète.
- Commencer par les validations ciblées, puis élargir seulement si nécessaire.

## Architecture Flutter

- L’application utilise GetX : routes dans `lib/app/routes`, fonctionnalités dans `lib/app/modules`, modèles et services dans `lib/app/data`.
- Garder la logique métier dans les controllers/services et les widgets centrés sur l’affichage.
- Réutiliser les modèles, services, bindings et composants existants avant d’en créer de nouveaux.
- Toute nouvelle chaîne visible doit respecter le système de localisation existant.

## Qualité et sécurité

- Ne pas modifier les changements locaux sans rapport avec la tâche.
- Ne pas ajouter de dépendance sans justification et sans vérifier si une dépendance existante couvre le besoin.
- Pour un bug, reproduire puis ajouter un test de régression quand c’est raisonnable.
- Validation minimale : `rtk dart format <fichiers>`, `rtk flutter analyze <fichiers>` et tests ciblés.
- Ne jamais contourner les règles Firestore côté client ; toute évolution de données doit considérer `firestore.rules` et les index.

## Fin de tâche

Résumer les fichiers modifiés, les validations exécutées et tout risque ou travail restant. Ne jamais prétendre qu’un test non exécuté a réussi.
