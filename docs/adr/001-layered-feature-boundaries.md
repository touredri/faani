# ADR 001 — Frontières par fonctionnalité et cas d’usage

## Statut

Accepté le 2026-07-11.

## Contexte

Les controllers GetX historiques cumulaient état UI, règles métier, accès Firebase, navigation et cycle de session. `AccueilController`, `AuthController`, `CommandeController` et `ProfileController` formaient des ponts entre de nombreuses communautés Graphify.

## Décision

L’application conserve GetX pour la présentation et la navigation, avec les frontières suivantes :

1. Les widgets expriment des intentions et reçoivent leurs dépendances importantes explicitement.
2. Les controllers traduisent ces intentions en état observable.
3. Les règles pures et orchestrations métier vivent dans `lib/app/domain/`.
4. Les accès Firebase, HTTP et SharedPreferences sont derrière des ports et adaptateurs dans `lib/app/data/`.
5. Le cycle de vie des composants liés à l’utilisateur est géré par `SessionCoordinator`.
6. Un controller ne dépend pas d’un controller d’une autre fonctionnalité pour récupérer une donnée métier; la donnée est passée explicitement ou exposée par un port.

## Conséquences

- Les règles de feed et la création de commande sont testables sans Firebase ni GetX.
- Les erreurs partielles de commande ont une stratégie de compensation.
- Les bindings deviennent la composition root GetX.
- Les nouveaux ports ajoutent quelques fichiers, mais réduisent le couplage et facilitent les tests.
- Les modules historiques non touchés seront migrés progressivement lorsqu’ils évoluent.

## Garde-fous

- `test/architecture/module_boundaries_test.dart` protège les frontières critiques déjà extraites.
- Toute exception à la règle de dépendance inter-controller doit être documentée dans un ADR.
- Après un changement structurel, exécuter `rtk graphify update` et comparer les god nodes.
