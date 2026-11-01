# Layouts 1.1.4 — Édition anglaise

Cette archive compile l’édition anglaise, avec les miniatures 16:10 sans libellés et le panneau de menu assorti à EvniaControl. L’interface reste en anglais quelle que soit la langue de macOS.

Layouts organise les fenêtres du Mac par glisser-déposer. Déplacez une fenêtre sur l’une des quatre cibles flottantes et relâchez la souris pour appliquer la disposition.

[English documentation](README.md) · [État de validation](VALIDATION.md)

## Menu et curseurs

Les deux réglages du menu utilisent le composant `TahoePillSlider` d’EvniaControl : même piste de 6 points et même poignée arrondie Liquid Glass de 20 × 16 points.

La marge se règle de 0 à 40 points, et la taille centrée de 30 à 100 %, par pas de 5 %. Les valeurs par défaut restent 12 points et 60 %. Les aperçus des cibles suivent les réglages.

Le menu s’ouvre depuis l’icône de Layouts et se ferme par un deuxième clic, un clic extérieur ou Échap. Les boutons Options et Quitter restent en bas. L’aide d’autorisation Accessibilité apparaît dans le menu si nécessaire.

## Options

La petite fenêtre d’options contient uniquement :

- Afficher l’icône dans la barre des menus.
- Lancer Layouts à l’ouverture de session.

Elle est recentrée exactement à chaque ouverture sur la zone utile de l’écran du pointeur. Si l’icône est masquée, relancer `Layouts.app` pour rouvrir les options. Une erreur du service de lancement peut afficher un message sous les deux cases.

## Deux éditions distinctes

L’archive FR produit la version française ; l’archive EN produit la version anglaise. Chaque édition garde sa langue, quelle que soit la langue du système ou une ancienne préférence enregistrée. Il n’y a ni sélecteur ni préférence de langue.

Le script copie uniquement la traduction de l’édition dans l’application. Les deux tables restent dans le projet source commun pour le développement et la vérification. Pour changer d’édition, utiliser l’autre archive. Les anciennes valeurs de marge, de taille, de visibilité de l’icône et de lancement à l’ouverture de session sont conservées.

## Dispositions

| Cible | Résultat |
| --- | --- |
| Plein écran | Zone utile moins la marge ; ne crée pas un nouvel espace plein écran macOS |
| Gauche | Moitié gauche de la zone utile |
| Droite | Moitié droite de la zone utile |
| Centré | Pourcentage de la largeur et de la hauteur, centré sur les deux axes |

Les cibles suivent l’écran du pointeur et respectent le Dock et la barre des menus. Les fenêtres soumises à une taille minimale sont repositionnées après redimensionnement.

Les quatre cibles affichent uniquement leur miniature d’écran au format 16:10, centrée dans la carte, sans les mentions « Plein écran », « Gauche », « Droite » et « Centré ». La taille des cartes est conservée. Leurs noms restent disponibles pour VoiceOver.

## Liquid Glass et accessibilité

Les fonds des quatre cibles utilisent la variante transparente `clear` de Liquid Glass sur macOS 26 et 27, pour laisser apparaître le bureau et les fenêtres derrière eux, dans l’esprit du Dock. Le panneau sous la barre des menus reprend le verre `regular` d’EvniaControl, plus dense, avec un rayon de 16 points et une découpe arrondie du contenu et du cadre de fenêtre. Le rendu exact dépend de macOS et reste à vérifier sur un Mac. Les miniatures restent gris clair et le survol utilise la couleur d’accent.

L’option système **Augmenter le contraste** rétablit le verre `regular`, plus dense, pour les cibles ; le menu utilise déjà ce style. **Réduire la transparence** utilise un fond opaque. Ces changements sont pris en compte pendant l’utilisation. Le composant des curseurs est repris d’EvniaControl, avec un garde de disponibilité pour les anciens systèmes. La réduction des animations est respectée. Des matériaux de repli permettent de conserver macOS 13 comme version minimale.

Au premier lancement, autoriser Layouts dans **Réglages Système → Confidentialité et sécurité → Accessibilité**. L’enregistrement de l’écran n’est pas requis. Les cibles ne prennent pas le focus et laissent passer le glissement.

## Compiler sur Mac

Le script demande Swift 6.4 ou ultérieur et le SDK macOS 27 ou ultérieur, accessibles par `xcrun`. Il n’impose pas Xcode complet et n’appelle pas `xcodebuild`.

Depuis le dossier de l’édition décompressée :

```bash
./test-geometry.sh
./test-localization.sh
./build.sh && open build/Layouts.app
```

Si les droits d’exécution ont été retirés, lancer d’abord `chmod +x *.sh`. Le script compile pour l’architecture du Mac, vérifie l’exécutable et la signature puis publie l’application. Un échec conserve l’application précédente. La signature est ad hoc par défaut ; `CODE_SIGN_IDENTITY` permet d’utiliser une identité Apple Development.

Le projet peut aussi être ouvert dans Xcode. L’application n’utilise aucune dépendance tierce ni service réseau.

Les archives contiennent les sources. L’environnement de préparation est sous Linux, sans Swift ni SDK macOS : la compilation et le rendu restent à vérifier sur un Mac. Voir `VALIDATION.md`.
