USE master;
GO

IF DB_ID(N'lab7') IS NOT NULL
    BEGIN
        ALTER DATABASE lab7 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE lab7;
        PRINT N'Existing database Lab6 has been deleted';
    END
ELSE
    BEGIN
        PRINT N'Database Lab7 not found';
    END
GO

CREATE DATABASE lab7
    ON (NAME = lab7_dat,
    FILENAME = N'D:\studying\db\lab7\lab7_dat.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%)
    LOG ON (NAME = lab7_log,
    FILENAME = N'D:\studying\db\lab7\lab7_log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO

USE lab7;
GO

IF OBJECT_ID(N'Team', N'U') IS NOT NULL
    BEGIN
        DROP TABLE Team;
    END;
GO

IF OBJECT_ID(N'Match', N'U') IS NOT NULL
    BEGIN
        DROP TABLE Match;
    END;
GO


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

CREATE TABLE Match
(
    MatchID       INT PRIMARY KEY IDENTITY (1,1),
    TeamAID       INT      NULL,
    TeamBID       INT      NULL,
    StartDateTime DATE     NOT NULL,
    Stage         NVARCHAR(50),
    MatchDuration SMALLINT NOT NULL,
    ScoreTeamA    TINYINT  NOT NULL,
    ScoreTeamB    TINYINT  NOT NULL,
    CONSTRAINT AK_Match UNIQUE (TeamAID, TeamBID, StartDateTime),
    CONSTRAINT Fk_Match_TeamA
        FOREIGN KEY (TeamAID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    CONSTRAINT Fk_Match_TeamB
        FOREIGN KEY (TeamBID)
            REFERENCES Team (TeamID)
            ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    CONSTRAINT CK_Match_DifferentTeams CHECK (TeamAID <> TeamBID)
);
GO

INSERT INTO Team(TeamName, CoachName, Country, FoundedDate, TotalEarning)
VALUES ('Team1', 'Coach1', 'country1', '2020-11-11', 10000),
       ('Team2', 'Coach2', 'country2', '2021-11-11', 15000),
       ('Team3', 'Coach3', 'country3', '2022-01-01', 20000);
GO


INSERT INTO Match(TeamAID, TeamBID, StartDateTIme, Stage, MatchDuration, ScoreTeamA, ScoreTeamB)
VALUES (1, 2, '2023-11-12 15:00:00', 'Group', 45, 16, 14),
       (1, 3, '2023-11-13 18:30:00', 'Playoff', 50, 10, 20),
       (2, 3, '2023-11-14 20:00:00', 'Final', 60, 5, 7);
GO

-- 1 --
IF OBJECT_ID(N'vm_MatchDetail') IS NOT NULL
    BEGIN
        DROP VIEW vm_MatchDetail;
    END
GO

CREATE VIEW vm_MatchDetail AS
SELECT TeamID,
       TeamName,
       CoachName,
       Country,
       FoundedDate,
       TotalEarning
FROM Team;
GO

-- 2 --
IF OBJECT_ID(N'vm_MatchWithTeam') IS NOT NULL
    BEGIN
        DROP VIEW vm_MatchWithTeam;
    END
GO

CREATE VIEW vm_MatchWithTeam AS
SELECT m.MatchID,
       m.StartDateTime,
       m.Stage,
       m.ScoreTeamA,
       m.ScoreTeamB,
       ta.TeamName AS TeamAName,
       tb.TeamName AS TeamBName
FROM Match AS m
         JOIN Team AS ta ON m.TeamAID = ta.TeamID
         JOIN Team AS tb ON m.TeamBID = tb.TeamID

GO

-- 3 --
IF EXISTS(SELECT 1
          FROM sys.indexes
          WHERE name = N'IX_Match_Teams_StartDateTime'
            AND object_id = OBJECT_ID(N'Match'))
    BEGIN
        DROP INDEX IX_Match_Teams_StartDateTime ON Match;
    END
GO

CREATE NONCLUSTERED INDEX IX_Match_Teams_StartDateTime
    ON Match (TeamAID, TeamBID, StartDateTime)
    INCLUDE (Stage, MatchDuration, ScoreTeamA, ScoreTeamB)
GO

SELECT *
FROM Match
WHERE TeamAID = 1
  AND TeamBID = 2
  AND StartDateTime >= '2023-01-01'
GO

-- 4 --

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'vm_IndexedMatchDetail') IS NOT NULL
    BEGIN
        DROP VIEW vm_IndexedMatchDetail;
    END
GO

IF EXISTS(SELECT 1
          FROM sys.indexes
          WHERE name = N'IX_vm_IndexedMatchDetail'
            AND object_id = OBJECT_ID(N'vm_IndexedMatchDetail'))
    BEGIN
        DROP INDEX IX_vm_IndexedMatchDetail ON vm_IndexedMatchDetail;
    END
GO

CREATE VIEW vm_IndexedMatchDetail
    WITH SCHEMABINDING
AS
SELECT TeamID,
       TeamName,
       CoachName,
       Country,
       FoundedDate,
       TotalEarning
FROM dbo.Team;
GO

CREATE UNIQUE CLUSTERED INDEX IX_vm_IndexedMatchDetail
    ON vm_IndexedMatchDetail (TeamID)
GO

SELECT *
FROM vm_MatchDetail
SELECT *
FROM vm_MatchWithTeam
SELECT *
FROM vm_IndexedMatchDetail