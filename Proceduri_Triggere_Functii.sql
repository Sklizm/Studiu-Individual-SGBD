	USE BazaGeo_DB;

	-- Procedura: Inserare marfa noua
	CREATE PROCEDURE usp_AddMarfa
    @ID_Marfa VARCHAR(10),
    @Denumire VARCHAR(100),
    @ID_Tip VARCHAR(10),
    @ID_Furnizor VARCHAR(10),
    @Pret_unitar FLOAT,
    @Stoc INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Furnizor WHERE ID_Furnizor = @ID_Furnizor)
    BEGIN
        RAISERROR('Furnizorul nu există!', 16, 1);
        RETURN;
    END

    INSERT INTO Marfa(ID_Marfa, Denumire, ID_Tip, ID_Furnizor, Pret_unitar, Stoc)
    VALUES (@ID_Marfa, @Denumire, @ID_Tip, @ID_Furnizor, @Pret_unitar, @Stoc);
END
GO

-- Exemplu
-- Mai întâi adăugăm un furnizor pentru test
INSERT INTO Furnizor(ID_Furnizor, Denumire_furnizor)
VALUES ('F1', 'Metro');

-- Rulăm procedura
EXEC usp_AddMarfa
    @ID_Marfa = 'M1',
    @Denumire = 'Lapte 3.5%',
    @ID_Tip = 'T1',
    @ID_Furnizor = 'F1',
    @Pret_unitar = 12.5,
    @Stoc = 50;

    EXEC usp_AddMarfa
    @ID_Marfa = 'M2',
    @Denumire = 'Ouă 10 buc.',
    @ID_Tip = 'T1',
    @ID_Furnizor = 'FX',  -- nu există
    @Pret_unitar = 20,
    @Stoc = 30;



    -- Procedura: Listarea Intrarilor cu furnizorul
    CREATE PROCEDURE usp_GetIntrariByFurnizor
    @ID_Furnizor VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT I.ID_Intrare, I.Data_intrare, F.Denumire_furnizor
    FROM Intrari I
    JOIN Furnizor F ON I.ID_Furnizor = F.ID_Furnizor
    WHERE I.ID_Furnizor = @ID_Furnizor;
END
GO

-- Exemplu
INSERT INTO Intrari(ID_Intrare, ID_Furnizor, Data_intrare)
VALUES ('I1', 'F1', '2025-01-01');

INSERT INTO Intrari(ID_Intrare, ID_Furnizor, Data_intrare)
VALUES ('I2', 'F1', '2025-02-15');
EXEC usp_GetIntrariByFurnizor @ID_Furnizor = 'F1';


    -- Trigger: Actualizarea stocului cand se insereaza o pozitie
    CREATE TRIGGER TR_UpdateStoc_OnInsertPozitie
ON Pozitii_intrari
AFTER INSERT
AS
BEGIN
    UPDATE M
    SET M.Stoc = M.Stoc + I.Cantitate
    FROM Marfa M
    JOIN inserted I ON M.ID_Marfa = I.ID_Marfa;
END
GO

-- Exemplu
-- Inseram marfa cu stoc mic
INSERT INTO Marfa(ID_Marfa, Denumire, ID_Tip, ID_Furnizor, Pret_unitar, Stoc)
VALUES ('M3', 'Zahăr 1kg', 'T2', 'F1', 15, 10);
-- Inseram o pozitie in Pozitii_Intrari Triggerul va creste stocul
INSERT INTO Pozitii_intrari(ID_Intrare, ID_Marfa, Cantitate)
VALUES ('I1', 'M3', 25);
-- Verificam stocul actualizat
SELECT * FROM Marfa WHERE ID_Marfa = 'M3';


    -- Trigger: Nu permite stergerea furnizorilor daca exista marfa asociata
    CREATE TRIGGER TR_BlockDeleteFurnizor
ON Furnizor
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Marfa M 
        JOIN deleted D ON M.ID_Furnizor = D.ID_Furnizor
    )
    BEGIN
        RAISERROR('Nu poți șterge furnizorul deoarece există marfă asociată!', 16, 1);
        RETURN;
    END
    
    DELETE FROM Furnizor
    WHERE ID_Furnizor IN (SELECT ID_Furnizor FROM deleted);
END
GO

-- Exemplu
DELETE FROM Furnizor WHERE ID_Furnizor = 'F1';
-- Adăugăm un furnizor fără marfă
INSERT INTO Furnizor(ID_Furnizor, Denumire_furnizor)
VALUES ('F2', 'Selgros');
-- Acum îl ștergem
DELETE FROM Furnizor WHERE ID_Furnizor = 'F2';


    -- Functie Scalara: Returneaza denumirea furnizorului dupa ID
    CREATE FUNCTION fn_GetFurnizorName (@ID_Furnizor VARCHAR(10))
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Name VARCHAR(50);

    SELECT @Name = Denumire_furnizor
    FROM Furnizor
    WHERE ID_Furnizor = @ID_Furnizor;

    RETURN @Name;
END
GO

    -- Exemplu
    SELECT dbo.fn_GetFurnizorName('FU001');


    -- Functie Tabelara: Lista marfa pentru un furnizor
    CREATE FUNCTION fn_MarfaSimpluByFurnizor (@ID_Furnizor VARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT ID_Marfa, Denumire, Pret_unitar, Stoc
    FROM MarfaSimplu
    WHERE ID_Furnizor = @ID_Furnizor
);
GO

    -- Exemplu
    SELECT * FROM dbo.fn_MarfaSimpluByFurnizor('FU001');
