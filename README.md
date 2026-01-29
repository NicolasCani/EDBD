# EDBD - Projet Académique CMA CGM

Ce projet de Master consiste en la conception d'un Entrepôt de Données (Data Warehouse) réalisé dans un cadre universitaire. L'étude s'appuie sur le cas réel de l'entreprise CMA CGM afin de modéliser des problématiques de traitement de données à grande échelle (Big Data).

L'objectif est d'analyser la rentabilité des opérations mondiales à travers deux axes majeurs :

    Le suivi du taux de remplissage des navires pour optimiser les routes maritimes.

    L'analyse des coûts de manutention (chargement/déchargement) dans les terminaux portuaires.

## Contenu du dépôt

- EDBD.pdf : Rapport complet présentant l'analyse des besoins, la modélisation et les diagrammes en étoile.

- tables_dimension.sql : Script de création des schémas (dimensions Navire, Port, Conteneur, Date et tables de faits).

- vues_materielles.sql : Implémentation de vues matérialisées pour optimiser les requêtes analytiques sur de gros volumes.

- bitmap.sql : Création d'index Bitmap pour accélérer les performances de filtrage.

- requetes.sql : Requêtes SQL complexes répondant aux besoins métier identifiés.

## Utilisation et Données

Les statistiques et chiffres clés utilisés pour dimensionner l'entrepôt (volumes de transport, flotte, effectifs) ont été récupérés sur le site officiel de CMA CGM.

L'entrepôt simule la gestion d'une flotte de plus de 650 navires desservant 420 ports.

Le modèle est conçu pour supporter des flux de données massifs, comme les 100 000 mouvements de conteneurs quotidiens rapportés par l'entreprise.

L'utilisation de bases de données SQL est ici indispensable : un tableur classique ne pourrait gérer les 237 250 lignes annuelles générées par le suivi des navires.

## Attention :

- Cadre du projet : Ce travail est un projet d'étudiant et n'est en aucun cas affilié, soutenu ou commandité par la société CMA CGM.

- Modélisation : Les mesures (additives et semi-additives) ont été définies pour répondre à des problématiques d'optimisation de remplissage et de coûts opérationnels.

- Performance : L'accent a été mis sur l'historisation via des modèles "updated-record" pour garantir la fiabilité des données malgré un haut volume de mises à jour quotidiennes.
