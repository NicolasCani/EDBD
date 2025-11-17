-- 1 
CREATE MATERIALIZED VIEW MV_Stats_Expedition_Mensuelle
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    -- 1. Dimensions de regroupement (Le "Grain" de la vue)
    D.Annee,
    D.Mois,
    E.Nom AS Nom_Entreprise,
    P_Dep.Nom_Port AS Port_Chargement,
    P_Arr.Nom_Port AS Port_Dechargement,
    -- 2. Pré-calcul des mesures (Agrégations)
    COUNT(*) AS Nb_Total_Expeditions,
    -- Calcul du nombre de conteneurs réfrigérés (basé sur Dim_Conteneur)
    SUM(CASE WHEN C.Est_Refrigere = 'Oui' THEN 1 ELSE 0 END) AS Nb_Conteneurs_Refrigeres,
    -- Somme des quantités (Attention : Quantite_Mouvement peut être -1 ou 1 selon votre schema)
    SUM(F.Quantite_Mouvement) AS Volume_Net_Mouvement,   
    -- Performance : Durée moyenne réelle et retard moyen
    AVG(F.Duree_Reel) AS Duree_Moyenne_Reelle,
    AVG(F.Duree_Reel - F.Duree_Prevu) AS Retard_Moyen_Jours
FROM Expedition F
    -- Jointure Temps (Sur la date de départ réelle pour situer l'action dans le temps)
    JOIN Dim_Date D ON F.ID_Date_Depart_Reel = D.ID_Date
    -- Jointure Entreprise (Directe depuis la table de faits )
    JOIN Dim_Entreprise E ON F.ID_Entreprise = E.ID_Entreprise
    -- Jointure Conteneur (Pour savoir si c'est réfrigéré [cite: 12])
    JOIN Dim_Conteneur C ON F.ID_Conteneur = C.ID_Conteneur
    -- Jointures Ports (Utilisation des clés de chargement/déchargement [cite: 18])
    JOIN Dim_Port P_Dep ON F.ID_Port_Chargement = P_Dep.ID_Port
    JOIN Dim_Port P_Arr ON F.ID_Port_Dechargement = P_Arr.ID_Port
GROUP BY
    D.Annee,
    D.Mois,
    E.Nom,
    P_Dep.Nom_Port,
    P_Arr.Nom_Port;


-- 2
CREATE MATERIALIZED VIEW MV_Taux_Remplissage_Navire
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    -- 1. Dimensions (Grain : Un Voyage spécifique d'un Navire)
    N.Nom_Navire,
    V.ID_Voyage,
    D.Annee,
    D.Mois,
    -- 2. Capacités Théoriques (Provient de la dimension Navire)
    N.Nb_Emplacement_Conteneur_Standard AS Capa_Max_Standard,
    N.Nb_Emplacement_Conteneur_Refrigere AS Capa_Max_Refrigere,
    -- 3. Occupation Réelle (Calculée via CASE WHEN sur la dimension Conteneur)
    SUM(CASE WHEN C.Est_Refrigere = 'Non' THEN 1 ELSE 0 END) AS Nb_Reel_Standard,
    SUM(CASE WHEN C.Est_Refrigere = 'Oui' THEN 1 ELSE 0 END) AS Nb_Reel_Refrigere,
    -- 4. Taux de Remplissage (Calculés en % avec sécurité division par zéro)
    ROUND(
        (SUM(CASE WHEN C.Est_Refrigere = 'Non' THEN 1 ELSE 0 END) / NULLIF(N.Nb_Emplacement_Conteneur_Standard, 0)) * 100
    , 2) AS Taux_Remplissage_Standard_Pct,
    ROUND(
        (SUM(CASE WHEN C.Est_Refrigere = 'Oui' THEN 1 ELSE 0 END) / NULLIF(N.Nb_Emplacement_Conteneur_Refrigere, 0)) * 100
    , 2) AS Taux_Remplissage_Refrigere_Pct
FROM Expedition F
    JOIN Dim_Navire N ON F.ID_Navire = N.ID_Navire
    JOIN Dim_Conteneur C ON F.ID_Conteneur = C.ID_Conteneur
    JOIN Dim_Voyage V ON F.ID_Voyage = V.ID_Voyage
    JOIN Dim_Date D ON F.ID_Date_Depart_Reel = D.ID_Date
GROUP BY
    N.Nom_Navire,
    V.ID_Voyage,
    D.Annee,
    D.Mois,
    N.Nb_Emplacement_Conteneur_Standard,
    N.Nb_Emplacement_Conteneur_Refrigere;