# Faani — contexte du produit

Faani connecte des clients et des tailleurs autour des modèles de vêtements traditionnels, des mesures, des commandes et de leur suivi.

## Socle technique

- Flutter/Dart, navigation et injection avec GetX.
- Firebase Authentication, Cloud Firestore, Storage, Messaging et App Check.
- Android et iOS sont des plateformes de production.
- Les fonctionnalités sont regroupées dans `lib/app/modules`; l’accès aux données est centralisé dans `lib/app/data/services` et les objets métier dans `lib/app/data/models`.

## Principes de développement

- La source de vérité métier doit rester dans les services et modèles, pas dans les widgets.
- Les autorisations doivent être appliquées dans Firestore en plus des contrôles d’interface.
- Les parcours réseau doivent tolérer la perte de connexion et fournir un état utilisateur clair.
- Les changements doivent être incrémentaux et compatibles avec les données déjà présentes.

## Documentation vivante

Compléter ce fichier lorsqu’une décision métier stable est découverte. Pour une décision architecturale importante, créer un ADR dans `docs/adr/` avec le contexte, la décision et ses conséquences.

## Frontières architecturales

- `lib/app/modules/` contient la présentation GetX : vues, bindings et état observable.
- `lib/app/domain/` contient les politiques et cas d’usage testables sans GetX.
- `lib/app/data/repositories/` et `lib/app/data/services/` adaptent Firebase, HTTP et le stockage local aux ports du domaine.
- `SessionCoordinator` ferme les composants liés à l’utilisateur lors de toute sortie de session.
- Une donnée métier traversant deux modules doit être passée explicitement ou via un port, jamais récupérée dans le controller de l’autre module.

## Données Firebase critiques

- `users/{uid}` : profil, rôle, identité et appareil actif. Une personne ne modifie que son propre document, sauf opérations administratives autorisées.
- `modele/{modeleId}` : modèle publié par un tailleur, utilisé par le feed et les commandes.
- `commandes/{commandeId}` : commande client/tailleur. La création utilise un `requestId` stable comme identifiant pour limiter les doublons.
- `suiviEtat/{id}` : historique d’état rattaché à une commande.

Toute nouvelle écriture doit passer par un repository/service injectable et être vérifiée contre `firestore.rules`.
