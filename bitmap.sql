CREATE BITMAP INDEX BMI_Expedition_Refrigere
ON Expedition(Dim_Conteneur.Est_Refrigere)
FROM Expedition, Dim_Conteneur
WHERE Expedition.ID_Conteneur = Dim_Conteneur.ID_Conteneur;

-- Quel est le poids total des marchandises transportées en frigo cette année ?
SELECT SUM(E.Poids)
FROM Expedition E, Dim_Conteneur C
WHERE E.ID_Conteneur = C.ID_Conteneur
AND C.Est_Refrigere = 'Oui'; 