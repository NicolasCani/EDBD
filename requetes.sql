-- 1
-- Quelle entreprise a le plus gros volume de conteneurs réfrigérés au départ de Marseille en 2025 ?
SELECT 
    Nom_Entreprise, 
    SUM(Nb_Conteneurs_Refrigeres) as Total_Reefer
FROM 
    MV_Stats_Expedition_Mensuelle
WHERE 
    Port_Chargement = 'Port de Marseille'
    AND Annee = 2025
GROUP BY 
    Nom_Entreprise
ORDER BY 
    Total_Reefer DESC;

-- Quel est le mois le plus actif en termes de volume global, tous ports confondus ?
SELECT 
    Mois,
    SUM(Nb_Total_Expeditions) AS Total_Expeditions,
    SUM(Nb_Conteneurs_Refrigeres) AS Dont_Refrigeres
FROM 
    MV_Stats_Expedition_Mensuelle
WHERE 
    Annee = 2025
GROUP BY 
    Mois
ORDER BY 
    Total_Expeditions DESC;

-- Classement des entreprises par volume transporté et leur taux d'utilisation de conteneurs réfrigérés.
SELECT 
    Nom_Entreprise,
    SUM(Nb_Total_Expeditions) AS Total_Voyages,
    SUM(Nb_Conteneurs_Refrigeres) AS Total_Reefer,
    -- Calcul d'un ratio en % (arrondi à 2 décimales)
    ROUND( (SUM(Nb_Conteneurs_Refrigeres) / NULLIF(SUM(Nb_Total_Expeditions),0)) * 100, 2 ) AS Pourcentage_Reefer
FROM 
    MV_Stats_Expedition_Mensuelle
GROUP BY 
    Nom_Entreprise
ORDER BY 
    Total_Voyages DESC;


-- 2

-- Identifier les navires "sous-utilisés" en réfrigéré
SELECT 
    Nom_Navire,
    ID_Voyage,
    Mois,
    Capa_Max_Refrigere,
    Nb_Reel_Refrigere,
    Taux_Remplissage_Refrigere_Pct
FROM 
    MV_Taux_Remplissage_Navire
WHERE 
    Taux_Remplissage_Refrigere_Pct < 50
    AND Annee = 2025
ORDER BY 
    Taux_Remplissage_Refrigere_Pct ASC;


-- Performance Moyenne de la Flotte par Année
SELECT 
    Annee,
    -- On refait une moyenne des taux calculés dans la vue
    AVG(Taux_Remplissage_Standard_Pct) AS Taux_Moyen_Global_Standard,
    AVG(Taux_Remplissage_Refrigere_Pct) AS Taux_Moyen_Global_Refrigere
FROM 
    MV_Taux_Remplissage_Navire
GROUP BY 
    Annee;


-- Identifier les expéditions avec beaucoup de conteneurs réfrigérés (+ 80%) et peu de conteneurs ambient (-30%) 

SELECT 
    Nom_Navire,
    ID_Voyage,
    Mois,
    Annee,
    -- On affiche les taux pour vérification
    Taux_Remplissage_Refrigere_Pct AS Taux_Reefer,
    Taux_Remplissage_Standard_Pct AS Taux_Standard,
    
    -- Petit calcul bonus : le déséquilibre
    (Taux_Remplissage_Refrigere_Pct - Taux_Remplissage_Standard_Pct) AS Ecart_Utilisation
FROM 
    MV_Taux_Remplissage_Navire
WHERE 
    -- Condition 1 : Très forte demande en frigo
    Taux_Remplissage_Refrigere_Pct >= 80
    
    -- Condition 2 : Faible demande en standard
    AND Taux_Remplissage_Standard_Pct <= 30
ORDER BY 
    Taux_Remplissage_Refrigere_Pct DESC;