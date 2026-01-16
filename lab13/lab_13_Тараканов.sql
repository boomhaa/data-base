USE master;
GO

IF DB_ID(N'lab13_1') IS NOT NULL
    BEGIN
        ALTER DATABASE lab13_1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE lab13_1;
        PRINT N'Existing database lab13_1 has been deleted';
    END
ELSE
    BEGIN
        PRINT N'Database lab13_1 not found';
    END
GO

IF DB_ID(N'lab13_2') IS NOT NULL
    BEGIN
        ALTER DATABASE lab13_2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE lab13_2;
        PRINT N'Existing database lab13_2 has been deleted';
    END
ELSE
    BEGIN
        PRINT N'Database lab13_2 not found';
    END
GO

CREATE DATABASE lab13_1
    ON (NAME = lab13_1_dat,
    FILENAME = N'C:\dbLabs\lab13_1\lab13_1_dat.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%)
    LOG ON (NAME = lab13_1_log,
    FILENAME = N'C:\dbLabs\lab13_1\lab13_1_log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO

CREATE DATABASE lab13_2
    ON (NAME = lab13_2_dat,
    FILENAME = N'C:\dbLabs\lab13_2\lab13_2_dat.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%)
    LOG ON (NAME = lab13_2_log,
    FILENAME = N'C:\dbLabs\lab13_2\lab13_2_log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO

USE lab13_1;
GO

IF OBJECT_ID(N'PlayerPart1', 'U') IS NOT NULL
    BEGIN
        DROP TABLE PlayerPart1;
    END
GO

CREATE TABLE PlayerPart1
(
    PlayerID   INT PRIMARY KEY,
    NickName   NVARCHAR(50) NOT NULL,
    FirstName  NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NOT NULL,
    LastName   NVARCHAR(50) NOT NULL,
    BirthDate  DATE         NOT NULL CHECK (DATEADD(YEAR, 18, BirthDate) <= CAST(GETDATE() AS DATE)),
    Country    NVARCHAR(56) NOT NULL,
    Rating     INT          NOT NULL DEFAULT 0,
    CONSTRAINT AK_NickName UNIQUE (NickName),
    CONSTRAINT Seq_PlayerPart1 CHECK (PlayerID < 4)
);
GO

USE lab13_2;
GO

IF OBJECT_ID(N'PlayerPart2', 'U') IS NOT NULL
    BEGIN
        DROP TABLE PlayerPart2;
    END
GO

CREATE TABLE PlayerPart2
(
    PlayerID   INT PRIMARY KEY,
    NickName   NVARCHAR(50) NOT NULL,
    FirstName  NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NOT NULL,
    LastName   NVARCHAR(50) NOT NULL,
    BirthDate  DATE         NOT NULL CHECK (DATEADD(YEAR, 18, BirthDate) <= CAST(GETDATE() AS DATE)),
    Country    NVARCHAR(56) NOT NULL,
    Rating     INT          NOT NULL DEFAULT 0,
    CONSTRAINT AK_NickName UNIQUE (NickName),
    CONSTRAINT Seq_PlayerPart2 CHECK (PlayerID >= 4)
);
GO


IF OBJECT_ID(N'PlayerView', N'V') IS NOT NULL
    DROP VIEW PlayerView;
GO

CREATE VIEW PlayerView
AS
            SELECT *
        FROM lab13_1.dbo.PlayerPart1
    UNION ALL
        SELECT *
        FROM lab13_2.dbo.PlayerPart2;
GO

INSERT INTO PlayerView
VALUES (1,'Nick1', 'First1', 'Middle1', 'Last1', '2006-12-04', 'country1', 103),
       (2,'Nick2', 'First2', 'Middle2', 'Last2', '2003-12-05', 'country2', 99),
       (3,'Nick3', 'First3', 'Middle3', 'Last3', '2005-11-06', 'country3', 80),
       (5,'Nick4', 'First4', 'Middle4', 'Last4', '2004-10-07', 'country1', 120),
       (6,'Nick5', 'First5', 'Middle5', 'Last5', '2003-08-08', 'country4', 114)
GO

SELECT * FROM PlayerView
SELECT * FROM lab13_1.dbo.PlayerPart1
SELECT * FROM lab13_2.dbo.PlayerPart2
GO

DELETE FROM PlayerView WHERE NickName = 'Nick3'
GO

UPDATE PlayerView SET Rating = 120 WHERE NickName = 'Nick1'
GO

INSERT INTO PlayerView VALUES (7,'Nick6', 'First6', 'Middle6', 'Last6', '2002-08-08', 'country5', 104)
GO

UPDATE PlayerView SET PlayerID = 8 WHERE NickName = 'Nick1'

SELECT * FROM PlayerView
SELECT * FROM lab13_1.dbo.PlayerPart1
SELECT * FROM lab13_2.dbo.PlayerPart2
GO

