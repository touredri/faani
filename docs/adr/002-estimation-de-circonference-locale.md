# ADR 002 — Estimation de circonférence locale

## Statut

Accepté le 2026-07-13.

## Contexte

Le parcours de mesure guidée estime actuellement l'épaule et la longueur avec
des repères de pose, puis demande les circonférences manuellement. Le produit
doit désormais proposer une estimation automatique de `bras`, `hanche`,
`poitrine`, `taille`, `ventre` et `poignet`, sans transférer d'images hors de
l'appareil.

## Décision

L'estimation de circonférence est développée d'abord intégralement sur
l'appareil :

1. Le parcours collecte des captures guidées de face et de profil, avec la
   taille saisie comme première échelle de calibration. Un repère physique de
   dimension connue reste une amélioration à valider pour augmenter la
   précision.
2. Les images, contours et résultats intermédiaires restent en mémoire locale
   et ne sont ni stockés ni envoyés à Firebase ou à un service tiers.
3. Une estimation n'est préremplie que si les contrôles de cadrage, de pose et
   de confiance sont satisfaits. Sinon le champ reste manuel.
4. Chaque valeur automatiquement proposée reste modifiable avant sauvegarde.
5. La précision est validée contre des mesures au mètre ruban sur un jeu de
   test représentatif avant de retirer le repli manuel pour une mesure.

La première implémentation utilise le masque de silhouette ML Kit et les
repères de pose déjà présents. Elle ne conserve en mémoire que des diamètres
normalisés par image, puis les combine entre la vue de face et la vue de
profil. Les valeurs proposées restent modifiables et sont rejetées lorsque la
qualité ou la stabilité de capture est insuffisante.

## Conséquences

- Le modèle et les traitements de contour doivent pouvoir fonctionner sur
  Android et iOS sans réseau.
- Le poids de l'application et le temps d'inférence doivent être suivis à
  chaque ajout de modèle.
- Une estimation par simples ratios de repères de pose ne peut pas être
  présentée comme une circonférence fiable.
- Le protocole de capture et le jeu de validation sont des éléments produit
  nécessaires avant toute promesse de précision.

## Garde-fous

- Aucun octet d'image ne doit atteindre Firebase, HTTP, un journal applicatif
  ou le stockage persistant.
- Les erreurs doivent être mesurées par champ et par type de capture, par
  rapport à une mesure manuelle de référence.
- Le repli manuel demeure obligatoire tant que le seuil d'acceptation de la
  mesure n'est pas démontré.
