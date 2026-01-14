USE master;
GO

IF DB_ID(N'lab11') IS NOT NULL
BEGIN
    ALTER DATABASE lab11 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE lab11;
END
GO

IF DB_ID(N'lab11') IS NOT NULL
    BEGIN
        ALTER DATABASE lab11 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE lab11;
        PRINT N'Existing database lab11 has been deleted';
    END
ELSE
    BEGIN
        PRINT N'Database lab11 not found';
    END
GO

CREATE DATABASE lab11
    ON (NAME = lab11_dat,
    FILENAME = N'C:\dbLabs\lab11\lab11_dat.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%)
    LOG ON (NAME = lab11_log,
    FILENAME = N'C:\dbLabs\lab11\lab11_log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO

USE lab11;
GO

/* ---------- 1) Таблицы ---------- */

-- 1.1 TEAM
CREATE TABLE dbo.TEAM
(
    TeamID        int IDENTITY(1,1) NOT NULL,
    TeamName      nvarchar(50)  NOT NULL,
    CoachName     nvarchar(50)  NOT NULL,
    Country       nvarchar(56)  NOT NULL,
    FoundedDate   date          NOT NULL,
    TotalEarning  money         NOT NULL CONSTRAINT DF_TEAM_TotalEarning DEFAULT (0),

    CONSTRAINT PK_TEAM PRIMARY KEY CLUSTERED (TeamID),
    CONSTRAINT UQ_TEAM_TeamName UNIQUE (TeamName),
    CONSTRAINT CK_TEAM_TotalEarning CHECK (TotalEarning >= 0),
    CONSTRAINT CK_TEAM_FoundedDate CHECK (FoundedDate <= CONVERT(date, GETDATE()))
);
GO

-- 1.2 PLAYER
CREATE TABLE dbo.PLAYER
(
    PlayerID   int IDENTITY(1,1) NOT NULL,
    NickName   nvarchar(50) NOT NULL,
    FirstName  nvarchar(50) NOT NULL,
    MiddleName nvarchar(50) NULL,
    LastName   nvarchar(50) NOT NULL,
    BirthDate  date NOT NULL,
    Country    nvarchar(56) NOT NULL,
    Rating     int NOT NULL,

    CONSTRAINT PK_PLAYER PRIMARY KEY CLUSTERED (PlayerID),
    CONSTRAINT UQ_PLAYER_NickName UNIQUE (NickName),
    CONSTRAINT CK_PLAYER_Rating CHECK (Rating BETWEEN 0 AND 10000),
    CONSTRAINT CK_PLAYER_BirthDate CHECK (BirthDate < CONVERT(date, GETDATE()))
);
GO

-- 1.3 SPONSOR
CREATE TABLE dbo.SPONSOR
(
    SponsorID    int IDENTITY(1,1) NOT NULL,
    CompanyName  nvarchar(100) NOT NULL,
    PhoneNumber  nvarchar(16)  NOT NULL,
    WebSite      nvarchar(255) NOT NULL,
    Email        nvarchar(320) NOT NULL,

    CONSTRAINT PK_SPONSOR PRIMARY KEY CLUSTERED (SponsorID),
    CONSTRAINT UQ_SPONSOR_CompanyName UNIQUE (CompanyName),
    CONSTRAINT CK_SPONSOR_Email CHECK (Email LIKE '%_@_%._%')
);
GO

-- 1.4 MATCH
CREATE TABLE dbo.[MATCH]
(
    MatchID        int IDENTITY(1,1) NOT NULL,
    TeamAID        int NOT NULL,
    TeamBID        int NOT NULL,
    StartDateTime  datetime NOT NULL,
    Stage          nvarchar(50) NOT NULL,
    MatchDuration  smallint NOT NULL,
    ScoreTeamA     tinyint NOT NULL CONSTRAINT DF_MATCH_ScoreA DEFAULT (0),
    ScoreTeamB     tinyint NOT NULL CONSTRAINT DF_MATCH_ScoreB DEFAULT (0),

    CONSTRAINT PK_MATCH PRIMARY KEY CLUSTERED (MatchID),
    CONSTRAINT UQ_MATCH_TeamA_TeamB_Start UNIQUE (TeamAID, TeamBID, StartDateTime),

    CONSTRAINT FK_MATCH_TeamA FOREIGN KEY (TeamAID) REFERENCES dbo.TEAM(TeamID),
    CONSTRAINT FK_MATCH_TeamB FOREIGN KEY (TeamBID) REFERENCES dbo.TEAM(TeamID),

    CONSTRAINT CK_MATCH_TeamsDifferent CHECK (TeamAID <> TeamBID),
    CONSTRAINT CK_MATCH_Duration CHECK (MatchDuration BETWEEN 1 AND 10000)
);
GO

-- 1.5 PLAYER_TEAM_HISTORY
CREATE TABLE dbo.PLAYER_TEAM_HISTORY
(
    PlayerID     int NOT NULL,
    StartDate    date NOT NULL,
    EndDate      date NOT NULL,
    TransferFee  money NOT NULL CONSTRAINT DF_PTH_TransferFee DEFAULT (0),
    TeamID       int NOT NULL,
    Game         nvarchar(50) NULL,
    IsBenched    bit NULL CONSTRAINT DF_PTH_IsBenched DEFAULT (0),

    CONSTRAINT PK_PLAYER_TEAM_HISTORY PRIMARY KEY CLUSTERED (PlayerID, StartDate),
    CONSTRAINT FK_PTH_Player FOREIGN KEY (PlayerID) REFERENCES dbo.PLAYER(PlayerID),
    CONSTRAINT FK_PTH_Team   FOREIGN KEY (TeamID)   REFERENCES dbo.TEAM(TeamID),

    CONSTRAINT CK_PTH_Dates CHECK (EndDate >= StartDate),
    CONSTRAINT CK_PTH_TransferFee CHECK (TransferFee >= 0)
)
GO

-- 1.6 SPONSOR_TEAM_CONTRACT
CREATE TABLE dbo.SPONSOR_TEAM_CONTRACT
(
    TeamID     int NOT NULL,
    SponsorID  int NOT NULL,
    StartDate  date NOT NULL,
    EndDate    date NOT NULL,
    Amount     money NOT NULL,

    CONSTRAINT PK_SPONSOR_TEAM_CONTRACT PRIMARY KEY CLUSTERED (TeamID, SponsorID, StartDate),
    CONSTRAINT FK_STC_Team    FOREIGN KEY (TeamID)    REFERENCES dbo.TEAM(TeamID),
    CONSTRAINT FK_STC_Sponsor FOREIGN KEY (SponsorID) REFERENCES dbo.SPONSOR(SponsorID),

    CONSTRAINT CK_STC_Dates CHECK (EndDate >= StartDate),
    CONSTRAINT CK_STC_Amount CHECK (Amount >= 0)
);
GO

/* ---------- 2) ALTER TABLE ---------- */

-- 2.1 Добавление нового поля + значение по умолчанию
ALTER TABLE dbo.TEAM
ADD HomeCity nvarchar(50) NULL CONSTRAINT DF_TEAM_HomeCity DEFAULT (N'Unknown');
GO

-- 2.2 Изменение типа/размера поля
ALTER TABLE dbo.TEAM
ALTER COLUMN CoachName nvarchar(80) NOT NULL;
GO

-- 2.3 Пример добавления CHECK после создания
ALTER TABLE dbo.SPONSOR
ADD CONSTRAINT CK_SPONSOR_Phone CHECK (PhoneNumber LIKE '+%[0-9]%' OR PhoneNumber LIKE '[0-9]%');
GO

-- 2.4 Пример удаления ограничения и создания заново
ALTER TABLE dbo.SPONSOR DROP CONSTRAINT CK_SPONSOR_Phone;
GO
ALTER TABLE dbo.SPONSOR
ADD CONSTRAINT CK_SPONSOR_Phone CHECK (LEN(PhoneNumber) BETWEEN 7 AND 16);
GO

/* ---------- 3) Индексы ---------- */
CREATE NONCLUSTERED INDEX IX_PLAYER_Country_Rating ON dbo.PLAYER(Country, Rating);
CREATE NONCLUSTERED INDEX IX_TEAM_Country ON dbo.TEAM(Country);
CREATE NONCLUSTERED INDEX IX_MATCH_StartDateTime ON dbo.[MATCH](StartDateTime);
CREATE NONCLUSTERED INDEX IX_PTH_TeamID_EndDate ON dbo.PLAYER_TEAM_HISTORY(TeamID, EndDate);
GO

/* ---------- 4) Представления ---------- */

-- 4.1 Список матчей с названиями команд
CREATE VIEW dbo.vwMatchList
AS
SELECT
    m.MatchID,
    m.StartDateTime,
    m.Stage,
    A.TeamName AS TeamA,
    B.TeamName AS TeamB,
    m.ScoreTeamA,
    m.ScoreTeamB,
    m.MatchDuration
FROM dbo.[MATCH] AS m
INNER JOIN dbo.TEAM AS A ON A.TeamID = m.TeamAID
INNER JOIN dbo.TEAM AS B ON B.TeamID = m.TeamBID;
GO

-- 4.2 Текущий состав команд
CREATE VIEW dbo.vwTeamRosterCurrent
AS
SELECT
    t.TeamName,
    p.NickName,
    p.Country AS PlayerCountry,
    h.Game,
    h.IsBenched,
    h.StartDate,
    h.EndDate
FROM dbo.PLAYER_TEAM_HISTORY h
INNER JOIN dbo.PLAYER p ON p.PlayerID = h.PlayerID
INNER JOIN dbo.TEAM t ON t.TeamID = h.TeamID
WHERE h.StartDate = (
    SELECT MAX(h2.StartDate)
    FROM dbo.PLAYER_TEAM_HISTORY h2
    WHERE h2.PlayerID = h.PlayerID
);
GO

/* ---------- 5) Функции ---------- */

-- 5.1 Скалярная: возраст игрока
CREATE FUNCTION dbo.fnPlayerAgeYears (@BirthDate date)
RETURNS int
AS
BEGIN
    DECLARE @age int = DATEDIFF(YEAR, @BirthDate, CONVERT(date, GETDATE()));
    IF (DATEADD(YEAR, @age, @BirthDate) > CONVERT(date, GETDATE()))
        SET @age = @age - 1;
    RETURN @age;
END;
GO

-- 5.2 Табличная: сумма контрактов по команде за период
CREATE FUNCTION dbo.fnTeamSponsorSum
(
    @TeamID   int,
    @DateFrom date,
    @DateTo   date
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        @TeamID AS TeamID,
        SUM(stc.Amount) AS TotalSponsorAmount
    FROM dbo.SPONSOR_TEAM_CONTRACT AS stc
    WHERE stc.TeamID = @TeamID
      AND stc.StartDate <= @DateTo
      AND stc.EndDate   >= @DateFrom
);
GO

/* ---------- 6) Хранимые процедуры ---------- */

-- 6.1 Добавление игрока
CREATE PROCEDURE dbo.uspAddPlayer
    @NickName nvarchar(50),
    @FirstName nvarchar(50),
    @MiddleName nvarchar(50) = NULL,
    @LastName nvarchar(50),
    @BirthDate date,
    @Country nvarchar(56),
    @Rating int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.PLAYER(NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating)
        VALUES (@NickName, @FirstName, @MiddleName, @LastName, @BirthDate, @Country, @Rating);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- 6.2 Добавление контракт спонсор-команда
CREATE PROCEDURE dbo.uspAddSponsorContract
    @TeamID int,
    @SponsorID int,
    @StartDate date,
    @EndDate date,
    @Amount money
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.SPONSOR_TEAM_CONTRACT(TeamID, SponsorID, StartDate, EndDate, Amount)
        VALUES (@TeamID, @SponsorID, @StartDate, @EndDate, @Amount);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- 6.3 Добавление сущностей M-M
CREATE PROCEDURE dbo.uspCreateTeamMandatoryBundle
    -- TEAM
    @TeamName nvarchar(50),
    @CoachName nvarchar(80),
    @TeamCountry nvarchar(56),
    @FoundedDate date,
    @HomeCity nvarchar(50),

    -- SPONSOR CONTRACT
    @SponsorID int,
    @ContractStart date,
    @ContractEnd date,
    @ContractAmount money,

    -- PLAYER + HISTORY
    @NickName nvarchar(50),
    @FirstName nvarchar(50),
    @MiddleName nvarchar(50) = NULL,
    @LastName nvarchar(50),
    @BirthDate date,
    @PlayerCountry nvarchar(56),
    @Rating int,

    @HistStart date,
    @HistEnd date,
    @TransferFee money = 0,
    @Game nvarchar(50) = NULL,
    @IsBenched bit = 0,

    -- MATCH
    @OpponentTeamID int,
    @MatchStartDateTime datetime,
    @Stage nvarchar(50),
    @MatchDuration smallint,
    @ScoreNewTeam tinyint,
    @ScoreOpponent tinyint,
    @WinPrize money = 0,

    -- OUT
    @NewTeamID int OUTPUT,
    @NewPlayerID int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- TEAM
        INSERT INTO dbo.TEAM(TeamName, CoachName, Country, FoundedDate, HomeCity)
        VALUES (@TeamName, @CoachName, @TeamCountry, @FoundedDate, @HomeCity);

        SET @NewTeamID = SCOPE_IDENTITY();

        -- CONTRACT
        INSERT INTO dbo.SPONSOR_TEAM_CONTRACT(TeamID, SponsorID, StartDate, EndDate, Amount)
        VALUES (@NewTeamID, @SponsorID, @ContractStart, @ContractEnd, @ContractAmount);

        -- PLAYER
        INSERT INTO dbo.PLAYER(NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating)
        VALUES (@NickName, @FirstName, @MiddleName, @LastName, @BirthDate, @PlayerCountry, @Rating);

        SET @NewPlayerID = SCOPE_IDENTITY();

        -- HISTORY
        INSERT INTO dbo.PLAYER_TEAM_HISTORY(PlayerID, StartDate, EndDate, TransferFee, TeamID, Game, IsBenched)
        VALUES (@NewPlayerID, @HistStart, @HistEnd, @TransferFee, @NewTeamID, @Game, @IsBenched);

        -- MATCH
        IF NOT EXISTS (SELECT 1 FROM dbo.TEAM WHERE TeamID = @OpponentTeamID)
            THROW 50010, N'OpponentTeamID не найден.', 1;

        IF @OpponentTeamID = @NewTeamID
            THROW 50011, N'Команда не может играть сама с собой.', 1;

        EXEC dbo.uspRecordMatch
            @TeamAID = @NewTeamID,
            @TeamBID = @OpponentTeamID,
            @StartDateTime = @MatchStartDateTime,
            @Stage = @Stage,
            @MatchDuration = @MatchDuration,
            @ScoreTeamA = @ScoreNewTeam,
            @ScoreTeamB = @ScoreOpponent,
            @WinPrize = @WinPrize;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO


-- 6.4 Провести матч и обновить TotalEarning победителю
CREATE PROCEDURE dbo.uspRecordMatch
    @TeamAID int,
    @TeamBID int,
    @StartDateTime datetime,
    @Stage nvarchar(50),
    @MatchDuration smallint,
    @ScoreTeamA tinyint,
    @ScoreTeamB tinyint,
    @WinPrize money = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.[MATCH](TeamAID, TeamBID, StartDateTime, Stage, MatchDuration, ScoreTeamA, ScoreTeamB)
        VALUES (@TeamAID, @TeamBID, @StartDateTime, @Stage, @MatchDuration, @ScoreTeamA, @ScoreTeamB);

        DECLARE @winner int = NULL;
        IF (@ScoreTeamA > @ScoreTeamB) SET @winner = @TeamAID;
        IF (@ScoreTeamB > @ScoreTeamA) SET @winner = @TeamBID;

        IF (@winner IS NOT NULL AND @WinPrize > 0)
        BEGIN
            UPDATE dbo.TEAM
            SET TotalEarning = TotalEarning + @WinPrize
            WHERE TeamID = @winner;
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* ---------- 7) Триггеры ---------- */

-- 7.1 Запрет удаления матчей
CREATE TRIGGER dbo.trg_NoDeleteMatch
ON dbo.[MATCH]
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR(N'Удаление MATCH запрещено: история матчей должна сохраняться.', 16, 1);
END;
GO

-- 7.2 Запрет удаления истории игрока
CREATE TRIGGER dbo.trg_NoDeletePlayerTeamHistory
ON dbo.PLAYER_TEAM_HISTORY
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR(N'Удаление PLAYER_TEAM_HISTORY запрещено: история выступлений должна сохраняться.', 16, 1);
END;
GO

-- 7.3 Запрет удаления контрактов
CREATE TRIGGER dbo.trg_NoDeleteSponsorTeamContract
ON dbo.SPONSOR_TEAM_CONTRACT
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR(N'Удаление SPONSOR_TEAM_CONTRACT запрещено: контракты должны сохраняться.', 16, 1);
END;
GO

-- 7.4 Запрет изменения суррогатных ключей
CREATE TRIGGER dbo.trg_NoUpdateTeamID
ON dbo.TEAM
AFTER UPDATE
AS
BEGIN
    IF UPDATE(TeamID)
    BEGIN
        RAISERROR(N'Изменение TeamID запрещено (суррогатный PK).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/* ---------- 8) Данные (НОВЫЙ ВАРИАНТ: M–M через процедуры) ---------- */

-- Sponsors
INSERT INTO dbo.SPONSOR(CompanyName, PhoneNumber, WebSite, Email)
VALUES
 (N'HyperTech', N'1234567890', N'https://hypertech.example', N'contact@hypertech.example'),
 (N'NovaBank',  N'9876543210', N'https://novabank.example',  N'info@novabank.example');

DECLARE @HyperTechID int = (SELECT SponsorID FROM dbo.SPONSOR WHERE CompanyName = N'HyperTech');
DECLARE @NovaBankID  int = (SELECT SponsorID FROM dbo.SPONSOR WHERE CompanyName = N'NovaBank');

-- Wolves
INSERT INTO dbo.TEAM(TeamName, CoachName, Country, FoundedDate, TotalEarning, HomeCity)
VALUES (N'Wolves', N'Ivan Mentor', N'USA', '2016-05-01', 250000, N'Austin');

DECLARE @WolvesID int = SCOPE_IDENTITY();

-- Обязательный контракт для Wolves
EXEC dbo.uspAddSponsorContract
    @TeamID=@WolvesID, @SponsorID=@HyperTechID,
    @StartDate='2024-01-01', @EndDate='2024-12-31', @Amount=120000;

-- Добавочный контракт Wolves
EXEC dbo.uspAddSponsorContract
    @TeamID=@WolvesID, @SponsorID=@NovaBankID,
    @StartDate='2024-06-01', @EndDate='2025-05-31', @Amount=200000;

-- Игрок Kira + история
INSERT INTO dbo.PLAYER(NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating)
VALUES (N'Kira', N'Anna', NULL, N'Lee', '2001-09-02', N'USA', 2600);

DECLARE @KiraID int = SCOPE_IDENTITY();

INSERT INTO dbo.PLAYER_TEAM_HISTORY(PlayerID, StartDate, EndDate, TransferFee, TeamID, Game, IsBenched)
VALUES (@KiraID, '2024-02-01', '2024-12-31', 25000, @WolvesID, N'CS2', 0);


-- Falcons
DECLARE @FalconsID int, @NeoID int;

EXEC dbo.uspCreateTeamMandatoryBundle
    @TeamName=N'Falcons', @CoachName=N'Alex Coach', @TeamCountry=N'Russia',
    @FoundedDate='2018-03-10', @HomeCity=N'Moscow',

    @SponsorID=@HyperTechID, @ContractStart='2024-01-01', @ContractEnd='2024-12-31', @ContractAmount=120000,

    @NickName=N'Neo', @FirstName=N'Vlad', @MiddleName=NULL, @LastName=N'Tar',
    @BirthDate='2002-04-14', @PlayerCountry=N'Russia', @Rating=2400,

    @HistStart='2024-01-01', @HistEnd='2024-12-31', @TransferFee=10000,
    @Game=N'CS2', @IsBenched=0,

    @OpponentTeamID=@WolvesID,
    @MatchStartDateTime='2024-10-01T18:00:00', @Stage=N'Group',
    @MatchDuration=90, @ScoreNewTeam=16, @ScoreOpponent=14, @WinPrize=50000,

    @NewTeamID=@FalconsID OUTPUT,
    @NewPlayerID=@NeoID OUTPUT;


-- Titans
DECLARE @TitansID int, @MaxID int;

EXEC dbo.uspCreateTeamMandatoryBundle
    @TeamName=N'Titans', @CoachName=N'John Lead', @TeamCountry=N'Germany',
    @FoundedDate='2019-11-15', @HomeCity=N'Berlin',
    @SponsorID=@HyperTechID, @ContractStart='2024-01-01', @ContractEnd='2024-12-31', @ContractAmount=120000,

    @NickName=N'Max', @FirstName=N'Max', @MiddleName=NULL, @LastName=N'Klein',
    @BirthDate='1999-12-11', @PlayerCountry=N'Germany', @Rating=2300,

    @HistStart='2024-03-01', @HistEnd='2024-12-31', @TransferFee=5000,
    @Game=N'Dota2', @IsBenched=1,

    @OpponentTeamID=@WolvesID,
    @MatchStartDateTime='2024-10-05T20:00:00', @Stage=N'Group',
    @MatchDuration=75, @ScoreNewTeam=10, @ScoreOpponent=16, @WinPrize=50000,

    @NewTeamID=@TitansID OUTPUT,
    @NewPlayerID=@MaxID OUTPUT;

GO

/* ---------- 9) DML-запросы для демонстрации возможностей ---------- */

-- 9.1 SELECT + DISTINCT
SELECT DISTINCT Country
FROM dbo.PLAYER
ORDER BY Country;

-- 9.2 Алиасы полей/таблиц + ORDER BY ASC/DESC
SELECT
    p.NickName AS Player,
    p.Rating   AS ELO,
    dbo.fnPlayerAgeYears(p.BirthDate) AS AgeYears
FROM dbo.PLAYER AS p
ORDER BY p.Rating DESC, p.NickName ASC;

-- 9.3 JOIN: INNER JOIN
SELECT *
FROM dbo.vwMatchList
ORDER BY StartDateTime DESC;

-- 9.4 LEFT JOIN
SELECT
    t.TeamName,
    s.CompanyName,
    stc.Amount
FROM dbo.TEAM t
LEFT JOIN dbo.SPONSOR_TEAM_CONTRACT stc ON stc.TeamID = t.TeamID
LEFT JOIN dbo.SPONSOR s ON s.SponsorID = stc.SponsorID
ORDER BY t.TeamName;

-- 9.5 RIGHT JOIN
SELECT
    s.CompanyName,
    t.TeamName,
    stc.Amount
FROM dbo.TEAM t
RIGHT JOIN dbo.SPONSOR_TEAM_CONTRACT stc ON stc.TeamID = t.TeamID
RIGHT JOIN dbo.SPONSOR s ON s.SponsorID = stc.SponsorID;

-- 9.6 FULL OUTER JOIN
SELECT
    t.TeamName,
    s.CompanyName,
    stc.Amount
FROM dbo.TEAM t
FULL OUTER JOIN dbo.SPONSOR_TEAM_CONTRACT stc ON stc.TeamID = t.TeamID
FULL OUTER JOIN dbo.SPONSOR s ON s.SponsorID = stc.SponsorID;

-- 9.7 WHERE: NULL / LIKE / BETWEEN / IN
SELECT *
FROM dbo.PLAYER
WHERE MiddleName IS NULL
  AND NickName LIKE N'%i%'      -- LIKE
  AND Rating BETWEEN 2000 AND 3000
  AND Country IN (N'Russia', N'USA');

-- 9.8 EXISTS
SELECT t.TeamName
FROM dbo.TEAM t
WHERE EXISTS (
    SELECT 1 FROM dbo.SPONSOR_TEAM_CONTRACT stc
    WHERE stc.TeamID = t.TeamID
);

-- 9.9 GROUP BY + агрегаты + HAVING
SELECT
    t.Country,
    COUNT(*) AS TeamsCount,
    SUM(t.TotalEarning) AS TotalEarningSum,
    AVG(CAST(t.TotalEarning AS float)) AS AvgEarning
FROM dbo.TEAM t
GROUP BY t.Country
HAVING SUM(t.TotalEarning) > 0
ORDER BY TotalEarningSum DESC;

-- 9.10 UNION / UNION ALL / EXCEPT / INTERSECT
-- UNION: страны (команды + игроки) без дублей
SELECT Country FROM dbo.TEAM
UNION
SELECT Country FROM dbo.PLAYER;

-- UNION ALL: с дублями
SELECT Country FROM dbo.TEAM
UNION ALL
SELECT Country FROM dbo.PLAYER;

-- INTERSECT: общие страны
SELECT Country FROM dbo.TEAM
INTERSECT
SELECT Country FROM dbo.PLAYER;

-- EXCEPT: страны команд, где нет игроков
SELECT Country FROM dbo.TEAM
EXCEPT
SELECT Country FROM dbo.PLAYER;

-- 9.11 Вложенный запрос: сумма спонсорства по команде за 2024 год
SELECT
    t.TeamName,
    (SELECT TotalSponsorAmount
     FROM dbo.fnTeamSponsorSum(t.TeamID, '2024-01-01', '2024-12-31')) AS SponsorSum2024
FROM dbo.TEAM t
ORDER BY SponsorSum2024 DESC;

-- 9.12 INSERT, SELECT
INSERT INTO dbo.SPONSOR(CompanyName, PhoneNumber, WebSite, Email)
SELECT
    CompanyName + N' (Branch)',
    PhoneNumber,
    WebSite,
    N'branch_' + Email
FROM dbo.SPONSOR
WHERE CompanyName = N'HyperTech';

-- 9.13 UPDATE
UPDATE dbo.PLAYER
SET Rating = Rating + 50
WHERE Country = N'Russia';

-- 9.14 DELETE
DELETE FROM dbo.SPONSOR
WHERE CompanyName LIKE N'%Branch%';

GO

/* ---------- 10) Проверки триггеров на удаление ---------- */
-- DELETE FROM dbo.[MATCH] WHERE MatchID = 1; -- Должно выдать ошибку
-- DELETE FROM dbo.PLAYER_TEAM_HISTORY WHERE PlayerID = (SELECT PlayerID FROM dbo.PLAYER WHERE NickName = N'Neo'); -- ОшS
