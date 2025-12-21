USE master;
GO

IF DB_ID(N'lab6') IS NOT NULL
    BEGIN
        ALTER DATABASE lab6 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE lab6;
        PRINT N'Existing database Lab6 has been deleted';
    END
ELSE
    BEGIN
        PRINT N'Database Lab6 not found';
    END
GO

CREATE DATABASE lab6
    ON (NAME = lab6_dat,
    FILENAME = N'D:\studying\db\lab6\lab6_dat.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%)
    LOG ON (NAME = lab6_log,
    FILENAME = N'D:\studying\db\lab6\lab6_log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO

USE lab6;
GO


-- 1 --
IF OBJECT_ID(N'Sponsor', N'U') IS NOT NULL
    BEGIN
        DROP TABLE Sponsor;
    END;
GO

CREATE TABLE Sponsor
(
    SponsorID   INT PRIMARY KEY IDENTITY (1,1),
    CompanyName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(16)  NOT NULL,
    WebSite     NVARCHAR(255) NOT NULL,
    Email       NVARCHAR(320) NOT NULL,
    CONSTRAINT AK_CompanyName UNIQUE (CompanyName)
)


INSERT INTO Sponsor (CompanyName, PhoneNumber, WebSite, Email)
VALUES ('company1', '+71111111111', 'web1.com', 'mail@web1.com')

SELECT SCOPE_IDENTITY() AS Scope_Identity,
       @@IDENTITY AS Identit,
       IDENT_CURRENT(N'Sponsor') AS Ident_Current
GO

-- 2 --

IF OBJECT_ID(N'Player', N'U') IS NOT NULL
    BEGIN
        DROP TABLE Player;
    END;
GO

CREATE TABLE Player
(
    PlayerID   INT PRIMARY KEY IDENTITY (1,1),
    NickName   NVARCHAR(50) NOT NULL,
    FirstName  NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50),
    LastName   NVARCHAR(50) NOT NULL,
    BirthDate  DATE         NOT NULL CHECK (DATEADD(YEAR, 18, BirthDate) <= CAST(GETDATE() AS DATE)),
    Country    NVARCHAR(56) NOT NULL,
    Rating     INT          NOT NULL DEFAULT 1,
    CONSTRAINT AK_NickName UNIQUE (NickName)
)
GO

INSERT INTO Player (NickName, FirstName, MiddleName, LastName, BirthDate, Country)
VALUES ('Nick1', 'First1', 'Middle1', 'Last1', '2006-12-04', 'country1')
GO
GO

-- 3 --
IF OBJECT_ID(N'SponsorGUID', N'U') IS NOT NULL
    BEGIN
        DROP TABLE SponsorGUID;
    END;
GO

CREATE TABLE SponsorGUID
(
    SponsorID   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    CompanyName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(16)  NOT NULL,
    WebSite     NVARCHAR(255) NOT NULL,
    Email       NVARCHAR(320) NOT NULL,
    CONSTRAINT AK_CompanyNameGUID UNIQUE (CompanyName)
)
GO


INSERT INTO SponsorGUID (CompanyName, PhoneNumber, WebSite, Email)
VALUES ('company2', '+72222222222', 'web2.com', 'mail@web2.com')
GO

-- 4 --
IF OBJECT_ID('Seq_SponsorID', 'SO') IS NOT NULL
    BEGIN
        DROP SEQUENCE Seq_SponsorID;
    END
GO

CREATE SEQUENCE dbo.Seq_SponsorID AS INT START WITH 1 INCREMENT BY 1;
GO

IF OBJECT_ID(N'SponsorSEQ', N'U') IS NOT NULL
    BEGIN
        DROP TABLE SponsorSEQ;
    END;
GO

CREATE TABLE SponsorSEQ
(
    SponsorID   INT PRIMARY KEY DEFAULT NEXT VALUE FOR Seq_SponsorID,
    CompanyName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(16)  NOT NULL,
    WebSite     NVARCHAR(255) NOT NULL,
    Email       NVARCHAR(320) NOT NULL,
    CONSTRAINT AK_CompanyNameSeq UNIQUE (CompanyName)
)
GO

INSERT INTO SponsorSEQ (CompanyName, PhoneNumber, WebSite, Email)
VALUES ('company3', '+73333333333', 'web3.com', 'mail@web3.com')
GO

-- 5 --

IF OBJECT_ID(N'Team', N'U') IS NOT NULL
    BEGIN
        DROP TABLE Team;
    END;
GO

-- Parent table --
CREATE TABLE Team
(
    TeamID       INT PRIMARY KEY IDENTITY (1,1),
    TeamName     NVARCHAR(50) NOT NULL,
    CoachName    NVARCHAR(50) NOT NULL,
    Country      NVARCHAR(56) NOT NULL,
    FoundedDate  DATE         NOT NULL,
    TotalEarning MONEY        NOT NULL DEFAULT 0,
    CONSTRAINT AK_TeamName UNIQUE (TeamName)
)
GO

INSERT INTO Team(TeamName, CoachName, Country, FoundedDate)
VALUES ('Team1', 'Coach1', 'country1', '2020-11-11');
GO

-- NO ACTION --

IF OBJECT_ID(N'Match_NoAction', N'U') IS NOT NULL
    BEGIN
        DROP TABLE Match_NoAction;
    END;
GO

CREATE TABLE Match_NoAction
(
    MatchID       INT PRIMARY KEY IDENTITY (1,1),
    TeamAID       INT      NULL,
    TeamBID       INT      NULL,
    StartDateTIme DATE     NOT NULL,
    Stage         NVARCHAR(50),
    MatchDuration SMALLINT NOT NULL,
    ScoreTeamA    TINYINT  NOT NULL,
    ScoreTeamB    TINYINT  NOT NULL,
    CONSTRAINT AK_Match_NoAction UNIQUE (TeamAID, TeamBID, StartDateTIme),
    CONSTRAINT Fk_Match_NoAction_TeamA
        FOREIGN KEY (TeamAID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    CONSTRAINT Fk_Match_NoAction_TeamB
        FOREIGN KEY (TeamBID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    CONSTRAINT CK_Match_NoAction_DifferentTeams CHECK (TeamAID <> TeamBID)
);
GO

INSERT INTO Team(TeamName, CoachName, Country, FoundedDate)
VALUES ('Team2', 'Coach2', 'country2', '2021-11-11');
GO

INSERT INTO Match_NoAction(TeamAID, TeamBID, StartDateTIme, Stage, MatchDuration, ScoreTeamA, ScoreTeamB)
VALUES (1, 2, '2020-11-12 11:00:00', 'stage1', 45, 16, 14);
GO

/*
DELETE
FROM Team
WHERE TeamID = 2
GO
*/

SELECT *
FROM Match_NoAction;
GO

-- CASCADE --
IF OBJECT_ID(N'Match_Cascade', N'U') IS NOT NULL
    BEGIN
        DROP TABLE Match_Cascade;
    END;
GO

CREATE TABLE Match_Cascade
(
    MatchID       INT PRIMARY KEY IDENTITY (1,1),
    TeamAID       INT      NULL,
    TeamBID       INT      NULL,
    StartDateTIme DATE     NOT NULL,
    Stage         NVARCHAR(50),
    MatchDuration SMALLINT NOT NULL,
    ScoreTeamA    TINYINT  NOT NULL,
    ScoreTeamB    TINYINT  NOT NULL,
    CONSTRAINT AK_Match_Cascade UNIQUE (TeamAID, TeamBID, StartDateTIme),
    CONSTRAINT Fk_Match_Cascade_TeamA
        FOREIGN KEY (TeamAID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    CONSTRAINT Fk_Match_Cascade_TeamB
        FOREIGN KEY (TeamBID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE CASCADE,
    CONSTRAINT CK_Match_Cascade_DifferentTeams CHECK (TeamAID <> TeamBID)
);
GO

INSERT INTO Team(TeamName, CoachName, Country, FoundedDate)
VALUES ('Team3', 'Coach3', 'country3', '2021-11-12');
GO

INSERT INTO Match_Cascade(TeamAID, TeamBID, StartDateTIme, Stage, MatchDuration, ScoreTeamA, ScoreTeamB)
VALUES (1, 3, '2020-11-12 15:00:00', 'stage1', 45, 16, 14);
GO

DELETE
FROM Team
WHERE TeamID = 3
GO

SELECT *
FROM Match_Cascade;
GO

-- SET DEFAULT --

IF OBJECT_ID(N'Match_SetDefault', N'U') IS NOT NULL
    BEGIN
        DROP TABLE Match_SetDefault;
    END;
GO

CREATE TABLE Match_SetDefault
(
    MatchID       INT PRIMARY KEY IDENTITY (1,1),
    TeamAID       INT      NULL DEFAULT 1,
    TeamBID       INT      NULL DEFAULT 2,
    StartDateTIme DATE     NOT NULL,
    Stage         NVARCHAR(50),
    MatchDuration SMALLINT NOT NULL,
    ScoreTeamA    TINYINT  NOT NULL,
    ScoreTeamB    TINYINT  NOT NULL,
    CONSTRAINT AK_Match_SetDefault UNIQUE (TeamAID, TeamBID, StartDateTIme),
    CONSTRAINT Fk_Match_SetDefault_TeamA
        FOREIGN KEY (TeamAID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    CONSTRAINT Fk_Match_SetDefault_TeamB
        FOREIGN KEY (TeamBID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE SET DEFAULT,
    CONSTRAINT CK_Match_SetDefault_DifferentTeams CHECK (TeamAID <> TeamBID)
);
GO

INSERT INTO Team(TeamName, CoachName, Country, FoundedDate)
VALUES ('Team4', 'Coach4', 'country4', '2021-11-13');
GO

INSERT INTO Match_SetDefault(TeamAID, TeamBID, StartDateTIme, Stage, MatchDuration, ScoreTeamA, ScoreTeamB)
VALUES (1, 4, '2020-11-12 18:00:00', 'stage1', 45, 16, 14);
GO

DELETE
FROM Team
WHERE TeamID = 4
GO

SELECT *
FROM Match_SetDefault;
GO

-- SET NULL --

IF OBJECT_ID(N'Match_SetNull', N'U') IS NOT NULL
    BEGIN
        DROP TABLE Match_SetNull;
    END;
GO

CREATE TABLE Match_SetNull
(
    MatchID       INT PRIMARY KEY IDENTITY (1,1),
    TeamAID       INT      NULL,
    TeamBID       INT      NULL,
    StartDateTIme DATE     NOT NULL,
    Stage         NVARCHAR(50),
    MatchDuration SMALLINT NOT NULL,
    ScoreTeamA    TINYINT  NOT NULL,
    ScoreTeamB    TINYINT  NOT NULL,
    CONSTRAINT AK_Match_SetNull UNIQUE (TeamAID, TeamBID, StartDateTIme),
    CONSTRAINT Fk_Match_SetNull_TeamA
        FOREIGN KEY (TeamAID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    CONSTRAINT Fk_Match_SetNull_TeamB
        FOREIGN KEY (TeamBID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE SET DEFAULT,
    CONSTRAINT CK_Match_SetNull_DifferentTeams CHECK (TeamAID <> TeamBID)
);
GO

INSERT INTO Team(TeamName, CoachName, Country, FoundedDate)
VALUES ('Team4', 'Coach4', 'country4', '2021-11-13');
GO

INSERT INTO Match_SetNull(TeamAID, TeamBID, StartDateTIme, Stage, MatchDuration, ScoreTeamA, ScoreTeamB)
VALUES (1, 5, '2020-11-12 18:00:00', 'stage1', 45, 16, 14);
GO

DELETE
FROM Team
WHERE TeamID = 5
GO

SELECT *
FROM Match_SetNull;
GO

-- Select data from tables of The first four points --

SELECT *
FROM Sponsor
SELECT *
FROM SponsorGUID
SELECT *
FROM SponsorSEQ
SELECT *
FROM Player
GO