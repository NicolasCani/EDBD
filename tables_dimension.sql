--------------------------------------------------------
-- 0. NETTOYAGE (DROP) DES TABLES
--------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Expedition CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Voyage CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Navire CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Port CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Date CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Conteneur CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Entreprise CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Pont_Entreprise_Hierarchie CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

--------------------------------------------------------
-- 1. CRÉATION DES TABLES DE DIMENSIONS
--------------------------------------------------------

-- Dimension Navire
CREATE TABLE Dim_Navire (
    ID_Navire NUMBER PRIMARY KEY,
    Nom_Navire VARCHAR2(100),
    Nb_Personnel NUMBER,
    Capacite NUMBER,
    Longueur NUMBER,
    Largeur NUMBER,
    Nb_Emplacement_Conteneur_Standard NUMBER,
    Nb_Emplacement_Conteneur_Refrigere NUMBER,
    Poids_Max NUMBER
);

-- Dimension Port
CREATE TABLE Dim_Port (
    ID_Port NUMBER PRIMARY KEY,
    Nom_Port VARCHAR2(100),
    Nom_Ville VARCHAR2(100),
    Nb_Emplacement_Navire NUMBER,
    Nb_Emplacement_Conteneur_Standard NUMBER,
    Nb_Emplacement_Conteneur_Refrigere NUMBER
);

-- Dimension Date
CREATE TABLE Dim_Date (
    ID_Date NUMBER PRIMARY KEY, -- Format YYYYMMDD
    Date_Complete DATE,
    Description VARCHAR2(50),
    Jour VARCHAR2(10),
    Mois VARCHAR2(20),
    Annee NUMBER,
    Annee_Fiscal NUMBER,
    Periode_Vacances VARCHAR2(3), -- 'Oui'/'Non'
    En_Semaine VARCHAR2(3) -- 'Oui'/'Non'
);

-- Dimension Conteneur
CREATE TABLE Dim_Conteneur (
    ID_Conteneur NUMBER PRIMARY KEY,
    Taille_Conteneur VARCHAR2(10),
    Statut VARCHAR2(50),
    Couleur VARCHAR2(30),
    Marque VARCHAR2(50),
    Est_Refrigere VARCHAR2(3), -- 'Oui'/'Non'
    Client VARCHAR2(100)
);

-- Dimension Entreprise (Client/Filiale)
CREATE TABLE Dim_Entreprise (
    ID_Entreprise NUMBER PRIMARY KEY,
    Nom VARCHAR2(100),
    Description VARCHAR2(255),
    Secteur VARCHAR2(100),
    Chiffre_Affaire NUMBER,
    Benefice NUMBER,
    Nb_Navire NUMBER
);

-- Dimension Voyage
CREATE TABLE Dim_Voyage (
    ID_Voyage NUMBER PRIMARY KEY,
    ID_Port_Depart NUMBER,
    ID_Port_Arrive NUMBER,
    CONSTRAINT fk_voyage_port_depart FOREIGN KEY (ID_Port_Depart) REFERENCES Dim_Port(ID_Port),
    CONSTRAINT fk_voyage_port_arrive FOREIGN KEY (ID_Port_Arrive) REFERENCES Dim_Port(ID_Port)
);

-- Table Pont pour la Hiérarchie des Entreprises (Partie facultative b)
CREATE TABLE Pont_Entreprise_Hierarchie (
    ID_Parent NUMBER,
    ID_Fils NUMBER,
    Nb_Niveaux NUMBER,
    PRIMARY KEY (ID_Parent, ID_Fils),
    CONSTRAINT fk_pont_parent FOREIGN KEY (ID_Parent) REFERENCES Dim_Entreprise(ID_Entreprise),
    CONSTRAINT fk_pont_fils FOREIGN KEY (ID_Fils) REFERENCES Dim_Entreprise(ID_Entreprise)
);


--------------------------------------------------------
-- 2. CRÉATION DE LA TABLE DE FAITS (EXPEDITION)
--------------------------------------------------------
CREATE TABLE Expedition (
    -- Clés étrangères (Contexte)
    ID_Navire NUMBER,
    ID_Voyage NUMBER,
    ID_Conteneur NUMBER,
    ID_Port_Chargement NUMBER,
    ID_Port_Dechargement NUMBER,
    ID_Date_Chargement NUMBER,
    ID_Date_Dechargement NUMBER,
    ID_Date_Annulation NUMBER,
    ID_Date_Depart_Prevu NUMBER,
    ID_Date_Arrive_Prevu NUMBER,
    ID_Date_Depart_Reel NUMBER,
    ID_Date_Arrive_Reel NUMBER,
    ID_Entreprise NUMBER,
    -- Mesures (Faits)
    Annulation NUMBER(1), -- 1 pour Oui, 0 pour Non
    Quantite_Mouvement NUMBER, -- 1 pour un chargement, -1 pour un déchargement
    Duree_Prevu NUMBER,
    Duree_Reel NUMBER,
    Poids NUMBER,
    Prix_Facture NUMBER,
    -- Définition des contraintes de clés étrangères
    CONSTRAINT fk_exp_navire FOREIGN KEY (ID_Navire) REFERENCES Dim_Navire(ID_Navire),
    CONSTRAINT fk_exp_voyage FOREIGN KEY (ID_Voyage) REFERENCES Dim_Voyage(ID_Voyage),
    CONSTRAINT fk_exp_conteneur FOREIGN KEY (ID_Conteneur) REFERENCES Dim_Conteneur(ID_Conteneur),
    CONSTRAINT fk_exp_entreprise FOREIGN KEY (ID_Entreprise) REFERENCES Dim_Entreprise(ID_Entreprise),
    -- Clés étrangères pointant vers les dimensions partagées (Port et Date)
    CONSTRAINT fk_exp_port_charge FOREIGN KEY (ID_Port_Chargement) REFERENCES Dim_Port(ID_Port),
    CONSTRAINT fk_exp_port_decharge FOREIGN KEY (ID_Port_Dechargement) REFERENCES Dim_Port(ID_Port),
    -- Clés étrangères pointant vers des dates
    CONSTRAINT fk_exp_date_charge FOREIGN KEY (ID_Date_Chargement) REFERENCES Dim_Date(ID_Date),
    CONSTRAINT fk_exp_date_decharge FOREIGN KEY (ID_Date_Dechargement) REFERENCES Dim_Date(ID_Date),
    CONSTRAINT fk_exp_date_annul FOREIGN KEY (ID_Date_Annulation) REFERENCES Dim_Date(ID_Date),
    CONSTRAINT fk_exp_date_dep_prevu FOREIGN KEY (  ID_Date_Depart_Prevu) REFERENCES Dim_Date(ID_Date),
    CONSTRAINT fk_exp_date_arr_prevu FOREIGN KEY (ID_Date_Arrive_Prevu) REFERENCES Dim_Date(ID_Date),
    CONSTRAINT fk_exp_date_dep_reel FOREIGN KEY (ID_Date_Depart_Reel) REFERENCES Dim_Date(ID_Date),
    CONSTRAINT fk_exp_date_arr_reel FOREIGN KEY (ID_Date_Arrive_Reel) REFERENCES Dim_Date(ID_Date)
);

--------------------------------------------------------
-- 3. PARTIE (a) : VUES VIRTUELLES POUR DIMENSIONS PARTAGÉES
--------------------------------------------------------

-- Vues pour la dimension Port
CREATE OR REPLACE VIEW V_Port_Chargement AS
SELECT 
    ID_Port AS ID_Port_Chargement,
    Nom_Port AS Nom_Port_Chargement,
    Nom_Ville AS Nom_Ville_Chargement
FROM Dim_Port;

CREATE OR REPLACE VIEW V_Port_Dechargement AS
SELECT 
    ID_Port AS ID_Port_Dechargement,
    Nom_Port AS Nom_Port_Dechargement,
    Nom_Ville AS Nom_Ville_Dechargement
FROM Dim_Port;


-- Vues pour la dimension Date
CREATE OR REPLACE VIEW V_Date_Chargement AS
SELECT 
    ID_Date AS ID_Date_Chargement,
    Date_Complete, Jour, Mois, Annee
FROM Dim_Date;

CREATE OR REPLACE VIEW V_Date_Dechargement AS
SELECT 
    ID_Date AS ID_Date_Dechargement,
    Date_Complete, Jour, Mois, Annee
FROM Dim_Date;

CREATE OR REPLACE VIEW V_Date_Annulation AS
SELECT 
    ID_Date AS ID_Date_Annulation,
    Date_Complete, Jour, Mois, Annee
FROM Dim_Date;

COMMIT;


