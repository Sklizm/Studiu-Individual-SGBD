CREATE LOGIN codrin
WITH PASSWORD = 'Codrin';
GO

CREATE LOGIN rita
WITH PASSWORD = 'Rita';
GO

CREATE USER codrin FOR LOGIN codrin;
CREATE USER rita FOR LOGIN rita;

CREATE DATABASE BazaGeo_DB;
GO

USE BazaGeo_DB;
GO

-- Acorda permisiuni utilizatorului codrin
GRANT SELECT, INSERT, UPDATE ON dbo.Furnizor TO codrin;
GRANT SELECT, INSERT ON Gestiune.Marfa TO codrin;

-- Acorda doar vizualizare (read-only) pentru rita
GRANT SELECT ON dbo.Intrari TO rita;

-- Retragere drepturi de modificare de la codrin
REVOKE INSERT, UPDATE ON dbo.Furnizor FROM codrin;

-- Retragere drepturi generale de la rita
REVOKE SELECT ON dbo.Intrari FROM rita;

CREATE TABLE Furnizor (
    ID_Furnizor VARCHAR(10) PRIMARY KEY NOT NULL,
    Denumire_furnizor VARCHAR(50) NOT NULL
);
GO

CREATE TABLE Marfa (
    ID_Marfa VARCHAR(10) PRIMARY KEY NOT NULL,
    Denumire VARCHAR(100) NOT NULL,
    ID_Tip VARCHAR(10) NULL,
    ID_Furnizor VARCHAR(10) FOREIGN KEY REFERENCES Furnizor(ID_Furnizor),
    Pret_unitar FLOAT NULL,
    Stoc INT NULL,
);
GO

CREATE TABLE Tip_Marfa (
    ID_Tip VARCHAR(10) PRIMARY KEY NOT NULL,
    Denumire_tip VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Intrari (
    ID_Intrare VARCHAR(15) PRIMARY KEY NOT NULL,
    Data_intrare DATETIME NULL,
    ID_Furnizor VARCHAR(10) FOREIGN KEY REFERENCES Furnizor(ID_Furnizor) NULL,
);
GO

CREATE TABLE Pozitii_intrari (
    ID_Pozitie VARCHAR(15) PRIMARY KEY NOT NULL,
    ID_Intrare VARCHAR(15) FOREIGN KEY REFERENCES Intrari(ID_Intrare) NULL,
    ID_Marfa VARCHAR(10) FOREIGN KEY REFERENCES Marfa(ID_Marfa) NULL,
    Cantitate FLOAT NULL,
    Pret_unitar FLOAT NULL,
);
GO

-- Selecturi simple
SELECT * FROM Furnizor;

SELECT * FROM Tip_Marfa;

SELECT * FROM Marfa;

SELECT * FROM Intrari;

SELECT * FROM Pozitii_intrari;

-- Toti furnizorii al caror nume contine 'Inventariere'
SELECT * FROM Furnizor
WHERE Denumire_furnizor LIKE '%Inventariere%';

-- Furnizori care nu contin 'Greece' in nume
SELECT * FROM Furnizor
WHERE Denumire_furnizor NOT LIKE '%Greece%';

-- Produse cu pret intre 100 si 1000
SELECT * FROM Marfa
WHERE Pret_unitar BETWEEN 100 AND 1000;

-- Numarul de produse pe fiecare furnizor, dar doar cei care au peste 3 produse
SELECT F.Denumire_furnizor, COUNT(M.ID_Marfa) AS NrProduse
FROM Furnizor F
JOIN Marfa M ON F.ID_Furnizor = M.ID_Furnizor
GROUP BY F.Denumire_furnizor
HAVING COUNT(M.ID_Marfa) > 3
ORDER BY NrProduse DESC;

-- Marfa provenita de la furnizorii care contin 'Sport' in denumire
SELECT * FROM Marfa
WHERE ID_Furnizor IN (
    SELECT ID_Furnizor 
    FROM Furnizor 
    WHERE Denumire_furnizor LIKE '%Sport%'
);

-- Produse care au pret peste media generala a produselor
SELECT Denumire, Pret_unitar FROM Marfa
WHERE Pret_unitar > (
    SELECT AVG(Pret_unitar)
    FROM Marfa
);

-- Index pe denumirea furnizorului (cautare rapida)
CREATE INDEX IX_Furnizor_Denumire
ON Furnizor(Denumire_furnizor);

-- Index compus pentru marfa: tip + furnizor
CREATE INDEX IX_Marfa_Tip_Furnizor
ON Marfa(ID_Tip, ID_Furnizor);

-- Tranzactii pe Intrari si Pozitii_intrari

BEGIN TRANSACTION;

INSERT INTO Intrari (ID_Intrare, Data_intrare, ID_Furnizor)
VALUES ('INTR998', GETDATE(), 'FU001');

IF @@ERROR <> 0
    ROLLBACK TRANSACTION;
ELSE
BEGIN
    INSERT INTO Pozitii_intrari (ID_Pozitie, ID_Intrare, ID_Marfa, Cantitate, Pret_unitar)
    VALUES ('POZIT999', 'INTR998', 'MA009', 50, 200);

    IF @@ERROR <> 0
        ROLLBACK TRANSACTION;
    ELSE
        COMMIT TRANSACTION;
END

/*DELETE FROM Pozitii_intrari   
WHERE ID_Pozitie = 'POZIT230';

DELETE FROM Intrari   
WHERE ID_Intrare = 'INTR998'; */

-- Securitate la vederi
-- Acordăm drept de SELECT pe vedere
GRANT SELECT ON vw_IntrariDetaliate TO rita;
GRANT SELECT ON vw_IntrariDetaliate TO codrin;




