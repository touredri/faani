# ADR 003 — Feed social « Pour vous / Suivis »

## Contexte

Faani doit combiner la découverte visuelle d’un réseau d’inspiration avec un
parcours de commande fiable. Le feed personnalisé existant classe les modèles
selon la nouveauté, les catégories et les interactions, mais il ne permettait
pas encore de retrouver les nouvelles publications des tailleurs suivis.

## Décision

L’accueil propose deux surfaces explicites :

- `Pour vous` conserve le classement personnalisé existant ;
- `Suivis` charge les modèles publics, approuvés et non rejetés des tailleurs
  suivis par l’utilisateur, triés par date de publication.

Le feed `Suivis` est chargé à la demande, limité aux 30 tailleurs suivis et aux
60 modèles les plus récents afin de préserver le temps de réponse et le coût
Firestore. Les modèles privés ou non approuvés sont filtrés avant affichage.

## Conséquences

- Le graphe social devient utile à la découverte sans créer un faux profil
  pour le contenu éditorial Faani.
- Un utilisateur non connecté reçoit un état explicite et peut revenir vers
  le feed public après connexion.
- Le feed dépend de la qualité du suivi : la prochaine étape est d’ajouter
  une suggestion de tailleurs basée sur les catégories et les interactions.
- La mise à jour des listes `following` et `followers` utilise désormais le
  bon identifiant dans chaque document.
