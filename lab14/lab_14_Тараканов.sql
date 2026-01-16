USE master;
GO

IF DB_ID(N'lab14_1') IS NOT NULL
    BEGIN
        ALTER DATABASE lab14_1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE lab14_1;
        PRINT N'Existing database Lab14_1 has been deleted';
    END
ELSE
    BEGIN
        PRINT N'Database lab14_1 not found';
    END
GO

IF DB_ID(N'lab14_2') IS NOT NULL
    BEGIN
        ALTER DATABASE lab14_2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE lab14_2;
        PRINT N'Existing database lab14_2 has been deleted';
    END
ELSE
    BEGIN
        PRINT N'Database lab14_2 not found';
    END
GO

CREATE DATABASE lab14_1
    ON (NAME = lab14_1_dat,
    FILENAME = N'C:\dbLabs\lab14_1\lab14_1_dat.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%)
    LOG ON (NAME = lab14_1_log,
    FILENAME = N'C:\dbLabs\lab14_1\lab14_1_log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO

CREATE DATABASE lab14_2
    ON (NAME = lab14_2_dat,
    FILENAME = N'C:\dbLabs\lab14_2\lab14_2_dat.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%)
    LOG ON (NAME = lab14_2_log,
    FILENAME = N'C:\dbLabs\lab14_2\lab14_2_log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO

USE lab14_1;
GO

IF OBJECT_ID(N'PlayerPart1_Ver', 'U') IS NOT NULL
    BEGIN
        DROP TABLE PlayerPart1_Ver;
    END
GO


CREATE TABLE PlayerPart1_Ver
(
    PlayerID   INT PRIMARY KEY,
    NickName   NVARCHAR(50) NOT NULL,
    FirstName  NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NOT NULL,
    LastName   NVARCHAR(50) NOT NULL,
    CONSTRAINT AK_NickName UNIQUE (NickName),
)
GO

USE lab14_2;
GO

IF OBJECT_ID(N'PlayerPart2_Ver', 'U') IS NOT NULL
    BEGIN
        DROP TABLE PlayerPart2_Ver;
    END
GO

CREATE TABLE PlayerPart2_Ver
(
    PlayerID  INT PRIMARY KEY,
    BirthDate DATE         NOT NULL CHECK (DATEADD(YEAR, 18, BirthDate) <= CAST(GETDATE() AS DATE)),
    Country   NVARCHAR(56) NOT NULL,
    Rating    INT          NOT NULL DEFAULT 0,
);
GO

USE lab14_1;
GO

IF OBJECT_ID(N'PlayerView_Ver', N'V') IS NOT NULL
    DROP VIEW PlayerView_Ver;
GO

CREATE VIEW PlayerView_Ver
AS
SELECT p1.PlayerID,
       p1.NickName,
       p1.FirstName,
       p1.MiddleName,
       p1.LastName,
       p2.BirthDate,
       p2.Country,
       p2.Rating
FROM lab14_1.dbo.PlayerPart1_Ver p1
         INNER JOIN lab14_2.dbo.PlayerPart2_Ver p2
                    ON p1.PlayerID = p2.PlayerID;
GO


IF OBJECT_ID(N'trg_InsertPlayerView_Ver', N'TR') IS NOT NULL
    DROP TRIGGER trg_InsertPlayerView_Ver;
GO

CREATE TRIGGER trg_InsertPlayerView_Ver
    ON PlayerView_Ver
    INSTEAD OF INSERT
    AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO lab14_1.dbo.PlayerPart1_Ver (PlayerID, NickName, FirstName, MiddleName, LastName)
    SELECT PlayerID, NickName, FirstName, MiddleName, LastName
    FROM inserted;

    INSERT INTO lab14_2.dbo.PlayerPart2_Ver (PlayerID, BirthDate, Country, Rating)
    SELECT PlayerID, BirthDate, Country, ISNULL(Rating, 0)
    FROM inserted;
END;
GO

IF OBJECT_ID(N'trg_UpdatePlayerView_Ver', N'TR') IS NOT NULL
    DROP TRIGGER trg_UpdatePlayerView_Ver;
GO

CREATE TRIGGER trg_UpdatePlayerView_Ver
    ON PlayerView_Ver
    INSTEAD OF UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(PlayerID)
        BEGIN
            RAISERROR (N'Нельзя изменить столбец PlayerID', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

    UPDATE p1
    SET p1.NickName   = i.NickName,
        p1.FirstName  = i.FirstName,
        p1.MiddleName = i.MiddleName,
        p1.LastName   = i.LastName
        FROM lab14_1.dbo.PlayerPart1_Ver p1
                 INNER JOIN inserted i ON p1.PlayerID = i.PlayerID;

        UPDATE p2
        SET p2.BirthDate = i.BirthDate,
            p2.Country   = i.Country,
            p2.Rating    = i.Rating
        FROM lab14_2.dbo.PlayerPart2_Ver p2
                 INNER JOIN inserted i ON p2.PlayerID = i.PlayerID;
    END;
    GO


    IF OBJECT_ID(N'trg_DeletePlayerView_Ver', N'TR') IS NOT NULL
        DROP TRIGGER trg_DeletePlayerView_Ver;
    GO

    CREATE TRIGGER trg_DeletePlayerView_Ver
        ON PlayerView_Ver
        INSTEAD OF DELETE
        AS
    BEGIN
        SET NOCOUNT ON;

        DELETE
        FROM lab14_1.dbo.PlayerPart1_Ver
        WHERE PlayerID IN (SELECT PlayerID FROM deleted);

        DELETE
        FROM lab14_2.dbo.PlayerPart2_Ver
        WHERE PlayerID IN (SELECT PlayerID FROM deleted);
    END;
    GO


    INSERT INTO PlayerView_Ver
    (PlayerID, NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating)
    VALUES (1, 'Nick1', 'First1', 'Middle1', 'Last1', '2006-12-04', 'country1', 103),
           (2, 'Nick2', 'First2', 'Middle2', 'Last2', '2003-12-05', 'country2', 99)
    GO

    SELECT *
    FROM PlayerView_Ver;
    GO

UPDATE PlayerView_Ver
SET Rating  = 150,
    Country = N'Russia'
WHERE NickName = N'Nick1';
GO

DELETE
FROM PlayerView_Ver
WHERE NickName = N'Nick2';
GO

SELECT *
FROM lab14_1.dbo.PlayerPart1_Ver;
SELECT *
FROM lab14_2.dbo.PlayerPart2_Ver;
GO