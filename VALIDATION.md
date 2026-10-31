# Validation — Layouts 1.1.4 — Édition française

L’environnement de préparation est sous Linux, sans Swift, Xcode ni SDK macOS. Aucun exécutable macOS n’est fourni. La compilation native et les essais visuels restent à effectuer sur un Mac.

## Modification actuelle — fond des quatre visuels

Seul le fond des quatre cartes flottantes passe au matériau transparent `clear`. Le code qui dessine les motifs a été rétabli à l’identique par comparaison octet par octet avec l’archive initiale : gris clair opaque (#CCCCCC), contours, légendes et survol d’origine. Le fond du menu et les contrôleurs de fenêtres correspondent également exactement aux sources initiales.

L’augmentation du contraste utilise un fond `regular` pour les cartes ; la réduction de transparence utilise un fond opaque. Ces réglages modifient le fond des cartes. Les motifs conservent leur remplissage opaque d’origine.

Contrôles de cette modification : comparaison des sources (un seul fichier Swift modifié, `LayoutTargetCardView.swift`), restauration exacte du dessin des motifs et du menu, syntaxe des trois scripts, métadonnées de langue, 20 clés de traduction et intégrité des deux archives. Les sources Swift sont identiques dans les deux éditions. Compilation, tests Swift et rendu natif restent à vérifier sur Mac.

Sur Mac, vérifier que le bureau et les fenêtres se voient à travers les fonds des quatre cartes, tandis que les motifs gardent le même gris opaque et le même survol qu’avant. Vérifier le menu, le glisser-déposer, les modes clair et sombre et le basculement des deux réglages d’accessibilité pendant l’affichage.

## Vérifications historiques — version 1.1.4

Les vérifications ci-dessous concernent la version de départ ; elles n’ont pas toutes été répétées pour cette correction.

Les contrôles statiques couvrent les scripts, les métadonnées, les références des sources et ressources du projet Xcode, les tables de traduction et l’intégrité des archives. Le composant TahoePillSlider est comparé au fichier d’EvniaControl ; seul le garde de disponibilité macOS 26 est ajouté. Les options sont vérifiées pour contenir exactement deux cases, sans curseur, sélecteur de langue ni bouton de permission.

Les tests simulés du script couvrent l’absence de xcodebuild, les SDK trop anciens, une édition invalide, les erreurs de compilation et de signature, l’absence d’exécutable et la conservation de l’application précédente. Les deux architectures et éditions sont assemblées avec leurs ressources respectives. Une variable LAYOUTS_LANGUAGE héritée est ignorée ; l’édition est fixée dans les métadonnées du paquet.

## À exécuter sur Mac

```bash
./test-geometry.sh
./test-localization.sh
./build.sh && open build/Layouts.app
```

Les tests Swift vérifient les calculs de disposition, le placement des cibles, du menu et des options, les traductions et les métadonnées de langue fixe. Ils ne sont pas exécutables ici en l’absence de swiftc.

## Essais restant à effectuer

- Depuis une autre application, cliquer une fois sur l’icône de Layouts : le panneau doit s’ouvrir immédiatement. Cliquer à nouveau : il doit se fermer sans se rouvrir. Répéter plusieurs fois, lentement puis rapidement, et après avoir utilisé un curseur du panneau.
- Vérifier la fermeture par Échap, un clic extérieur (dans une autre application ou dans les options de Layouts) et le changement d’application avec Commande-Tab. Le clic suivant sur l’icône doit rouvrir le panneau. Répéter après masquage puis réaffichage de l’icône et sur chaque écran.
- Vérifier que les deux curseurs du menu ont la même piste et poignée que dans EvniaControl. Régler la marge de 0 à 40 points et la taille de 30 à 100 %, avec les pas prévus.
- Déplacer une fenêtre sur chacune des quatre cibles et vérifier les aperçus et les positions.
- Vérifier que les formes et contours des quatre miniatures sont gris clair (#CCCCCC) en modes clair et sombre, y compris avec réduction de transparence et augmentation du contraste. Au survol, la forme doit prendre la couleur d’accent.
- Ouvrir les options : seules les deux cases de visibilité de l’icône et de lancement à l’ouverture de session doivent apparaître. Les déplacer, fermer et rouvrir : la fenêtre doit être recentrée sur l’écran du pointeur.
- Vérifier le lancement à l’ouverture de session et le masquage de l’icône. Relancer l’application pour rouvrir les options quand l’icône est masquée.
- Vérifier la version FR sur un système anglais et la version EN sur un système français. Une ancienne préférence de langue doit rester sans effet. Aucun sélecteur de langue ne doit apparaître.
- Vérifier que l’aide d’autorisation reste dans le menu quand Accessibilité manque, puis que l’indicateur change après autorisation.
- Répéter en modes clair et sombre, avec réduction de transparence, augmentation du contraste et réduction des animations. Vérifier aussi le matériau de repli sur macOS 13–15 et Liquid Glass sur macOS 26–27.
- Vérifier les écrans multiples, le placement du menu aux bords de l’écran et les changements de position du Dock.

L’absence d’utilisation de @State est contrôlée dans les sources. La compilation directe avec swiftc évite le contrôle de présence de Xcode complet ajouté puis retiré dans les versions précédentes. Ces vérifications statiques et simulées ne prouvent pas que le code compile ni que le rendu macOS est correct.
