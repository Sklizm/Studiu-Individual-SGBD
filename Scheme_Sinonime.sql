USE BazaGeo_DB;
GO

-- Schema noua pentru gestiunea produselor
CREATE SCHEMA Gestiune AUTHORIZATION dbo;
GO

-- Mutam tabelul Marfa in schema Gestiune
ALTER SCHEMA Gestiune TRANSFER dbo.Marfa;
GO

-- Sinonim pentru a accesa tabelul Gestiune.Marfa mai usor
CREATE SYNONYM MarfaSimplu FOR Gestiune.Marfa;
GO

-- Test: select din sinonim
SELECT TOP 5 * FROM MarfaSimplu;

-- Top 5 furnizori după valoarea totală a stocului (preț * cantitate)
SELECT TOP 5 
    F.Denumire_furnizor,
    SUM(M.Pret_unitar * M.Stoc) AS ValoareTotala
FROM Gestiune.Marfa M
JOIN Furnizor F ON F.ID_Furnizor = M.ID_Furnizor
WHERE M.Stoc IS NOT NULL AND M.Pret_unitar > 0
GROUP BY F.Denumire_furnizor
HAVING SUM(M.Pret_unitar * M.Stoc) > 10000
ORDER BY ValoareTotala DESC;


-- View cu lista completa de produse cu furnizor si tip
CREATE VIEW vw_ListaMarfaDetaliata AS
SELECT 
    M.ID_Marfa,
    M.Denumire AS Denumire_Marfa,
    F.Denumire_furnizor,
    T.Denumire_tip,
    M.Pret_unitar,
    M.Stoc
FROM Gestiune.Marfa M
LEFT JOIN Furnizor F ON M.ID_Furnizor = F.ID_Furnizor
LEFT JOIN Tip_Marfa T ON M.ID_Tip = T.ID_Tip;

SELECT * FROM vw_ListaMarfaDetaliata;

-- Valoarea totala a stocului per furnizor
CREATE VIEW vw_ValoareTotalaStocuri AS
SELECT 
    F.Denumire_furnizor,
    SUM(M.Pret_unitar * M.Stoc) AS ValoareTotalaStoc
FROM Gestiune.Marfa M
JOIN Furnizor F ON M.ID_Furnizor = F.ID_Furnizor
WHERE M.Stoc > 0
GROUP BY F.Denumire_furnizor
HAVING SUM(M.Pret_unitar * M.Stoc) > 5000;

SELECT * FROM vw_ValoareTotalaStocuri;

-- Evidenta intrarilor de marfa
CREATE VIEW vw_IntrariDetaliate AS
SELECT 
    I.ID_Intrare,
    I.Data_intrare,
    F.Denumire_furnizor,
    M.Denumire AS Marfa,
    P.Cantitate,
    P.Pret_unitar,
    (P.Cantitate * P.Pret_unitar) AS ValoarePozitie
FROM Intrari I
JOIN Furnizor F ON I.ID_Furnizor = F.ID_Furnizor
JOIN Pozitii_intrari P ON I.ID_Intrare = P.ID_Intrare
JOIN Gestiune.Marfa M ON P.ID_Marfa = M.ID_Marfa;

SELECT * FROM vw_IntrariDetaliate;
