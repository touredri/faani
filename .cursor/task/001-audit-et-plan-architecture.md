# Audit et plan de consolidation architecturale

> **Statut** : done  
> **Priorité** : haute  
> **Créé le** : 2026-07-11

## Contexte

Le graphe Graphify du projet contient 2 354 nœuds, 3 510 relations et 124 communautés. Les principaux « god nodes » sont `ProfileController`, `AccueilController`, `CommandeController`, `AuthController` et `UserModel`.

Cet audit distingue :

- les relations `EXTRACTED`, prouvées par les imports, définitions et références du code ;
- les regroupements de communautés, qui indiquent une proximité structurelle mais pas nécessairement un appel direct ;
- les risques architecturaux confirmés par une lecture ciblée des fichiers concernés.

## Synthèse exécutive

Le problème prioritaire n'est pas GetX en lui-même. Il vient du fait que plusieurs controllers jouent simultanément les rôles de présentation, orchestration métier, persistance, navigation et gestion de cycle de vie.

Le plan recommandé est incrémental : sécuriser les comportements par des tests, extraire les règles pures, introduire des services de cas d'usage, puis réduire progressivement les controllers. Aucun remplacement global de GetX ni réécriture complète n'est prévu.

## Analyses

### 1. Pourquoi `AccueilController` relie-t-il autant de communautés ?

Graphify lui attribue 12 relations et des voisins appartenant à 8 communautés. Il est structurellement relié au module accueil, à `GetxController`, à l'authentification, aux commandes, aux commentaires et à plusieurs vues.

La lecture du code nuance ce résultat : les styles et commentaires sont surtout importés par `AccueilView` et `accueil_model_view.dart`, pas directement par `AccueilController`. Graphify agrège donc une partie du couplage au niveau du module. En revanche, le controller concentre réellement :

- l'état du feed et les sélections de catégories/tailleurs ;
- un `PageController` et un `RefreshController`, donc de l'état de présentation ;
- les algorithmes de hero ranking, exploration, nouveauté et diversité ;
- le suivi d'engagement ;
- la mémoire des modèles ouverts et sa persistance dans `SharedPreferences` ;
- la pagination, le rafraîchissement et le cache ;
- des dépendances directes vers `UserController` et `HomeController`.

Avec 817 lignes, il constitue à la fois un controller UI, un moteur de recommandation et un orchestrateur de données. C'est la raison fonctionnelle de sa centralité.

**Risque :** toute évolution du feed peut affecter l'UI, les métriques, la persistance ou la session utilisateur. Les règles de ranking sont difficiles à tester sans initialiser GetX et Flutter.

**Cible :** conserver `AccueilController` comme adaptateur de présentation, extraire `FeedRankingPolicy`, `FeedRepository`, `FeedHistoryStore` et `FeedAnalytics`.

### 2. `AuthController` est un orchestrateur global de session

`AuthController` contient 752 lignes. Il gère OTP, Google Sign-In, utilisateur anonyme, erreurs Firebase, politique mono-appareil, navigation et données utilisateur.

À la déconnexion, `_disposeHomeFlowControllers()` connaît et détruit explicitement `ProfileController`, `CommandeController`, `FavorieController`, `AccueilController`, `HomeController` et `UserController`. Cela crée une dépendance inverse : l'authentification connaît tous les modules consommateurs de session.

**Risque :** ajouter un controller lié à la session exige de modifier l'authentification. Un oubli peut conserver des données d'un utilisateur après déconnexion.

**Cible :** introduire un `SessionCoordinator` responsable du démarrage et de la fermeture de session, puis laisser `AuthController` gérer uniquement les interactions d'authentification.

### 3. `CommandeController` mélange formulaire, stockage et workflow métier

Graphify lui attribue 11 relations dans 9 communautés, le plus grand étalement observé. Ses 334 lignes regroupent :

- l'état des champs de formulaire et du scroll ;
- la sélection de photo et l'upload Firebase Storage ;
- la validation client/tailleur ;
- la création de commande ;
- la création du premier état de suivi ;
- l'envoi et la programmation de notifications ;
- les changements de prix/date et l'acceptation d'une commande ;
- une dépendance runtime à `AccueilController` pour obtenir le tailleur sélectionné.

**Risque :** une création partiellement réussie peut laisser une photo ou une commande sans suivi/notification. La dépendance à `AccueilController` rend le cas d'usage inutilisable hors du parcours accueil.

**Cible :** passer explicitement le tailleur au cas d'usage et extraire `CreateOrderUseCase`, `OrderMediaService` et `OrderNotificationService`.

### 4. `ProfileController` couvre plusieurs sous-domaines

`ProfileController` est le nœud le plus connecté (14 relations) et couvre 7 communautés. Ses 292 lignes gèrent :

- édition du profil ;
- préférences et langue ;
- statistiques d'abonnement ;
- modèles du tailleur et pagination ;
- conversion d'un utilisateur en tailleur ;
- liens externes, notation et partage de l'application ;
- controllers de formulaire et ressources visuelles.

**Risque :** le cycle de vie du profil pilote des subscriptions et plusieurs formulaires sans frontière claire. Une modification du parcours tailleur peut perturber le profil standard.

**Cible :** séparer `ProfileController`, `TailorOnboardingController` et `TailorPortfolioController`; déplacer les liens externes dans un service dédié.

### 5. `UserModel` est partagé, ce qui est normal mais sensible

`UserModel` relie 6 communautés : profils tailleurs, listes, demandes, commentaires et affichage. Cette centralité est normale pour un modèle cœur, mais elle rend toute évolution de schéma risquée.

**Risque :** champs optionnels, différences entre utilisateur anonyme/client/tailleur et migrations Firestore implicites.

**Cible :** stabiliser le contrat de sérialisation, documenter les invariants par rôle et ajouter des tests de compatibilité sur les anciennes données.

### 6. Les vues contiennent encore de l'orchestration

Le couple `AccueilView`/`accueil_model_view.dart` représente 655 lignes. Les widgets déclenchent navigation, engagement, favoris, commentaires, commande et préchargement média.

**Risque :** logique dupliquée ou difficile à tester dans des widgets stateful volumineux.

**Cible :** créer des composants de feed focalisés et faire remonter les intentions utilisateur par callbacks ou méthodes de controller explicites.

### 7. Injection et cycle de vie GetX sont distribués

Plusieurs controllers utilisent `Get.find`, tandis que certains créent eux-mêmes leurs dépendances avec `Get.put`. Les bindings ne constituent donc pas l'unique composition root.

**Risque :** ordre d'initialisation implicite, erreurs « not registered », instances difficiles à remplacer en test et nettoyage incomplet.

**Cible :** enregistrer controllers et services dans les bindings ou dans un bootstrap de session unique. Interdire progressivement `Get.put` à l'intérieur des controllers.

### 8. Accès Firebase et fonctions globales traversent les couches

Des controllers appellent directement Firestore, Storage et `global_function.dart`, en parallèle de services dédiés.

**Risque :** règles métier et gestion d'erreur différentes selon le point d'appel; tests nécessitant Firebase.

**Cible :** faire passer tout accès distant par des repositories/services injectables avec erreurs typées.

### 9. Faible cohésion et nœuds isolés

Graphify signale 1 561 nœuds avec au plus une relation et des communautés à très faible cohésion, notamment autour de l'accueil, de l'authentification et de certains gros widgets. Une partie provient de symboles de framework ou de limites de l'extraction Dart; ce chiffre ne doit donc pas être traité comme 1 561 défauts.

**Action utile :** suivre plutôt l'évolution des relations entre fichiers métier, du nombre de dépendances inter-modules et de la taille des controllers.

## Architecture cible

```text
Vue / Widget
    ↓ intention utilisateur
Controller de présentation
    ↓ cas d'usage
Use case / politique métier pure
    ↓ ports injectables
Repository / service d'infrastructure
    ↓
Firebase, SharedPreferences, notifications, stockage
```

Les modèles métier ne doivent dépendre ni de Flutter, ni de GetX. Les controllers exposent l'état réactif et traduisent les résultats métier pour l'interface.

## Périmètre

### Inclus

- tests de caractérisation des parcours accueil, session, commande et profil ;
- extraction progressive des responsabilités métier ;
- centralisation du cycle de vie de session ;
- clarification des bindings GetX ;
- réduction des dépendances directes entre controllers ;
- documentation des frontières et suivi Graphify.

### Exclus

- remplacement de GetX ;
- changement visuel complet ;
- migration hors Firebase ;
- réécriture simultanée de tous les modules ;
- modification du schéma Firestore sans tâche dédiée.

## Plan d'implémentation

### Phase 0 — Baseline et garde-fous

- [x] Remplacer le test compteur générique par un smoke test du thème et du shell Flutter réel du projet.
- [x] Ajouter des tests de sérialisation pour `UserModel`, `Modele` et `Commande`.
- [x] Ajouter des tests de caractérisation pour déconnexion, chargement du feed et création de commande.
- [x] Documenter les collections Firestore et invariants client/tailleur dans `CONTEXT.md`.
- [x] Relever les métriques initiales : 2 354 nœuds, 3 510 arêtes, 126 alertes et 2 850 lignes ciblées.

**Sortie :** comportements critiques protégés avant extraction.

### Phase 1 — Rendre le ranking du feed testable

- [x] Créer `lib/app/domain/feed/feed_ranking_policy.dart` sans dépendance Flutter/GetX.
- [x] Déplacer les scores hero/exploration, pénalités, diversité et tie-breakers.
- [x] Construire des jeux de données déterministes et tester ordre, diversité et stabilité.
- [x] Injecter la policy dans `AccueilController` sans changer le rendu.

**Sortie :** algorithme de recommandation testable en Dart pur.

### Phase 2 — Extraire persistance et chargement du feed

- [x] Introduire un port `FeedRepository` autour de `ModeleService`.
- [x] Introduire `FeedHistoryStore` autour de `SharedPreferences`.
- [x] Introduire `FeedAnalytics` autour de `EngagementTrackingService`.
- [x] Déplacer cache, historique, pagination et rafraîchissement hors du controller.
- [x] Garder dans `AccueilController` uniquement l'état observable et les intentions UI.

**Sortie :** `AccueilController` ne connaît plus les détails de persistance.

### Phase 3 — Centraliser le cycle de session

- [x] Créer `SessionCoordinator` et définir les composants « session-scoped ».
- [x] Déplacer `_disposeHomeFlowControllers()` hors de `AuthController`.
- [x] Enregistrer les dépendances de session depuis les bindings/bootstrap.
- [x] Tester connexion A → déconnexion → connexion B sans fuite d'état.
- [x] Supprimer les `Get.put` internes aux controllers migrés.

**Sortie :** authentification découplée de la liste des modules applicatifs.

### Phase 4 — Fiabiliser la création de commande

- [x] Créer un objet `CreateOrderInput` indépendant des controllers.
- [x] Passer explicitement tailleur, client, modèle, mesure, date, prix et média.
- [x] Extraire upload, création, suivi initial et notifications dans un use case orchestré.
- [x] Définir les erreurs partielles et la stratégie de reprise/idempotence.
- [x] Retirer `Get.find<AccueilController>()` de `CommandeController`.
- [x] Tester les parcours client, tailleur et les échecs Firebase intermédiaires.

**Sortie :** création de commande indépendante du parcours d'entrée.

### Phase 5 — Scinder le profil

- [x] Déplacer la candidature tailleur dans `TailorOnboardingController`.
- [x] Déplacer modèles, catégories et pagination dans `TailorPortfolioController`.
- [x] Garder édition et préférences dans `ProfileController`.
- [x] Extraire partage, notation et URL dans `ExternalAppService`.
- [x] Vérifier l'annulation des subscriptions et la libération des controllers texte.

**Sortie :** trois controllers cohésifs avec cycles de vie indépendants.

### Phase 6 — Alléger les widgets d'accueil

- [x] Découper `AccueilView` en sections sans logique métier cachée.
- [x] Remplacer les accès globaux `Get.find` dans les items par des dépendances/callbacks explicites.
- [x] Centraliser les intentions ouvrir, commenter, aimer et commander.
- [x] Ajouter des tests sur chargement, erreur, vide, pagination et action utilisateur.

**Sortie :** widgets focalisés et comportements testables.

### Phase 7 — Uniformiser les accès aux données

- [x] Inventorier les appels directs à `FirebaseFirestore.instance`, Storage et fonctions globales.
- [x] Migrer d'abord les appels touchés par les phases précédentes vers des services injectables.
- [x] Introduire des erreurs de domaine traduites en messages UI localisés.
- [x] Vérifier les règles `firestore.rules` pour chaque écriture migrée.

**Sortie :** frontières d'infrastructure cohérentes sans migration big-bang.

### Phase 8 — Mesurer et verrouiller l'architecture

- [x] Lancer `flutter analyze` et la suite de tests complète.
- [x] Mettre à jour Graphify et comparer les ponts/communautés avant-après.
- [x] Ajouter une règle de revue : aucun controller ne dépend directement d'un controller d'un autre module sans justification.
- [x] Documenter les décisions durables dans `docs/adr/`.
- [x] Mettre à jour `CONTEXT.md` avec les frontières finales.

**Sortie :** amélioration mesurée et règles empêchant la régression.

## Ordre recommandé des lots

1. Baseline de tests.
2. Ranking pur du feed.
3. Persistance/chargement du feed.
4. Cycle de session.
5. Création de commande.
6. Découpage du profil.
7. Widgets et accès Firebase restants.
8. Audit final.

Chaque lot doit rester livrable indépendamment et conserver le comportement visible existant.

## Fichiers principalement concernés

- `lib/app/modules/accueil/controllers/accueil_controller.dart`
- `lib/app/modules/accueil/views/accueil_view.dart`
- `lib/app/modules/accueil/widgets/accueil_model_view.dart`
- `lib/app/modules/authentification/controllers/authentification_controller.dart`
- `lib/app/modules/commande/controllers/commande_controller.dart`
- `lib/app/modules/profile/controllers/profile_controller.dart`
- `lib/app/modules/**/bindings/*.dart`
- `lib/app/data/services/`
- `lib/app/data/models/`
- `firestore.rules`
- `test/`

## Critères de validation globaux

- [x] Aucun changement fonctionnel intentionnel sur les parcours existants; les comportements extraits sont couverts par régression.
- [x] Les règles de ranking principales sont couvertes par des tests Dart purs.
- [x] `AuthController` ne référence plus les controllers de fonctionnalités pour les détruire.
- [x] `CommandeController` ne dépend plus de `AccueilController`.
- [x] Les controllers migrés ne créent plus leurs propres dépendances avec `Get.put`.
- [x] Les subscriptions et controllers Flutter sont libérés dans `onClose`/`dispose`.
- [x] Les écritures Firebase migrées passent par des ports et les règles Firestore ont été vérifiées.
- [x] `dart format`, l'analyse ciblée et les 24 tests passent; les 120 alertes legacy sont suivies dans la tâche 002.
- [x] Le graphe Graphify est à jour et les frontières critiques sont verrouillées par un test d'architecture.

## Risques et stratégie de réduction

| Risque | Réduction |
|---|---|
| Régression du classement du feed | Golden datasets et comparaison ordre avant/après |
| Fuite d'état entre utilisateurs | Test connexion/déconnexion multi-utilisateur |
| Commande partiellement créée | Idempotence, erreurs typées et reprise explicite |
| Scope trop large | Lots verticaux, une responsabilité extraite à la fois |
| Sur-abstraction | Extraire uniquement les dépendances déjà exercées par des tests |
| Graphe imprécis | Confirmer chaque décision par lecture ciblée et tests |

## Commandes de validation

```bash
rtk dart format <fichiers-modifiés>
rtk flutter analyze <fichiers-modifiés>
rtk flutter test <tests-ciblés>
rtk graphify update
```

## Définition de terminé

Le plan est terminé : les critères globaux sont satisfaits, chaque phase possède ses tests de régression, les règles Firestore concernées ont été revues et le graphe final est enregistré. La dette d'analyse statique historique est suivie séparément dans `002-dette-analyse-statique.md`.
