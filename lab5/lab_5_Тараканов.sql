USE master;
GO

--1--
IF DB_ID(N'lab5') IS NOT NULL
    BEGIN
        ALTER DATABASE lab5 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE lab5;
        PRINT N'Existing database Lab5 has been deleted';
    END
ELSE
    BEGIN
        PRINT N'Database Lab5 not found';
    END
GO

CREATE DATABASE lab5
    ON (NAME = lab5_dat,
    FILENAME = N'C:\dbLabs\lab5\lab5_dat.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%)
    LOG ON (NAME = lab5_log,
    FILENAME = N'C:\dbLabs\lab5\lab5_log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO

--2--
USE lab5
GO

IF OBJECT_ID(N'Player') IS NOT NULL
    BEGIN
        DROP TABLE Player;
        PRINT N'Table Player has been deleted';
    END
GO

CREATE TABLE Player
(
    PlayerID   INT PRIMARY KEY,
    NickName   NVARCHAR(50) NOT NULL,
    FirstName  NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50),
    LastName   NVARCHAR(50) NOT NULL,
    BirthDate  DATE         NOT NULL,
    Country    NVARCHAR(56) NOT NULL,
    Rating     INT          NOT NULL,
    CONSTRAINT AK_NickName UNIQUE (NickName)
);
GO

SELECT *
FROM Player;
GO

--3--
ALTER DATABASE lab5
    ADD FILEGROUP LargeFileGroup;
GO

ALTER DATABASE lab5
    ADD FILE (
        NAME = Lab5_LargeData1,
        FILENAME = N'C:\dbLabs\lab5\lab5_dat1.ndf',
        SIZE = 5 MB,
        MAXSIZE = 25 MB,
        FILEGROWTH = 5%
        )
        TO FILEGROUP LargeFileGroup
GO

--4--
ALTER DATABASE lab5
    MODIFY FILEGROUP LargeFileGroup DEFAULT;
GO

--5--

IF OBJECT_ID(N'Sponsor') IS NOT NULL
    BEGIN
        DROP TABLE Sponsor;
        PRINT N'Table Sponsor has been deleted';
    END
GO

CREATE TABLE Sponsor
(
    SponsorID   INT PRIMARY KEY,
    CompanyName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(16)  NOT NULL,
    WebSite     NVARCHAR(255) NOT NULL,
    Email       NVARCHAR(320) NOT NULL,
    CONSTRAINT AK_CompanyName UNIQUE (CompanyName)
);
GO

SELECT *
FROM Sponsor;
GO

--insert--
INSERT INTO Player
(PlayerID, NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating)
VALUES (1, N'NickName', N'FirstName', N'MiddleName', N'LastName', '2006-04-12', N'Country', 100);
GO

INSERT INTO Sponsor
    (SponsorID, CompanyName, PhoneNumber, WebSite, Email)
VALUES (1, N'Company name', N'+71234567890', N'kakoytodomen.ru', N'email@site.ru');
GO


SELECT *
FROM Player
GO

SELECT *
FROM Sponsor
GO

--6--
ALTER DATABASE lab5
    MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO

IF OBJECT_ID(N'Sponsor2') IS NOT NULL
    BEGIN
        DROP TABLE Sponsor2;
    END
GO

SELECT * INTO Sponsor2 FROM Sponsor
GO

DROP TABLE Sponsor;
GO

ALTER DATABASE lab5
    REMOVE FILE Lab5_LargeData1;
GO

ALTER DATABASE lab5
    REMOVE FILEGROUP LargeFileGroup;
GO

SELECT * FROM Sponsor2;
GO

--7--
IF SCHEMA_ID(N'NewSchema') IS NOT NULL
    BEGIN
        IF OBJECT_ID(N'NewSchema.Player') IS NOT NULL
            BEGIN
                DROP TABLE NewSchema.Player;
                PRINT N'Existing table NewSchema.Player has been deleted'
            END
        DROP SCHEMA NewSchema;
        PRINT N'Existing schema NewSchema has been deleted'
    END
GO

CREATE SCHEMA NewSchema;
GO

ALTER SCHEMA NewSchema
    TRANSFER Player;
GO


IF OBJECT_ID(N'NewSchema.Player') IS NOT NULL
    BEGIN
        DROP TABLE NewSchema.Player;
        PRINT N'Existing table NewSchema.Player has been deleted'
    END
GO

DROP SCHEMA NewSchema;
GO

