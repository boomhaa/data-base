USE master;
GO

IF DB_ID(N'lab8') IS NOT NULL
    BEGIN
        ALTER DATABASE lab8 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE lab8;
        PRINT N'Existing database Lab6 has been deleted';
    END
ELSE
    BEGIN
        PRINT N'Database Lab8 not found';
    END
GO

CREATE DATABASE lab8
    ON (NAME = lab8_dat,
    FILENAME = N'D:\studying\db\lab8\lab8_dat.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%)
    LOG ON (NAME = lab8_log,
    FILENAME = N'D:\studying\db\lab8\lab8_log.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO

USE lab8;
GO

IF OBJECT_ID(N'Player', 'U') IS NOT NULL
    BEGIN
        DROP TABLE PLayer;
    END
GO

CREATE TABLE Player
(
    PlayerID   INT IDENTITY (1,1) PRIMARY KEY,
    NickName   NVARCHAR(50) NOT NULL,
    FirstName  NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NOT NULL,
    LastName   NVARCHAR(50) NOT NULL,
    BirthDate  DATE         NOT NULL CHECK (DATEADD(YEAR, 18, BirthDate) <= CAST(GETDATE() AS DATE)),
    Country    NVARCHAR(56) NOT NULL,
    Rating     INT          NOT NULL DEFAULT 0,
    CONSTRAINT AK_NickName UNIQUE (NickName)
);
GO

INSERT INTO Player (NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating)
VALUES ('Nick1', 'First1', 'Middle1', 'Last1', '2006-12-04', 'country1', 103),
       ('Nick2', 'First2', 'Middle2', 'Last2', '2003-12-05', 'country2', 99),
       ('Nick3', 'First3', 'Middle3', 'Last3', '2005-11-06', 'country3', 80),
       ('Nick4', 'First4', 'Middle4', 'Last4', '2004-10-07', 'country1', 120),
       ('Nick5', 'First5', 'Middle5', 'Last5', '2003-08-08', 'country4', 114)
GO

-- 1 --
IF OBJECT_ID(N'GetPlayersCursor', N'P') IS NOT NULL
    BEGIN
        DROP PROCEDURE getPlayersCursor
    END
GO

CREATE PROCEDURE GetPlayersCursor @cursor CURSOR VARYING OUTPUT,
                                  @minRating INT
AS
BEGIN
    SET @cursor = CURSOR FORWARD_ONLY STATIC FOR
        SELECT * FROM Player WHERE Rating >= @minRating;
    OPEN @cursor
END
GO

-- 1.Test --
DECLARE @cursor1 CURSOR

DECLARE
    @PlayerID INT ,
    @NickName NVARCHAR(50) ,
    @FirstName NVARCHAR(50) ,
    @MiddleName NVARCHAR(50),
    @LastName NVARCHAR(50) ,
    @BirthDate DATE,
    @Country NVARCHAR(56),
    @Rating INT;


EXECUTE GetPlayersCursor @cursor = @cursor1 OUTPUT, @minRating = 100
FETCH NEXT FROM @cursor1 INTO
    @PlayerID, @NickName, @FirstName, @MiddleName, @LastName, @BirthDate, @Country, @Rating
WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @PlayerID   AS PlayerID,
               @NickName   AS NickName,
               @FirstName  AS FirstName,
               @MiddleName AS MiddleName,
               @LastName   AS LastName,
               @BirthDate  AS BirthDate,
               @Country    AS Country,
               @Rating     AS Rating;
        FETCH NEXT FROM @cursor1 INTO
            @PlayerID, @NickName, @FirstName, @MiddleName, @LastName, @BirthDate, @Country, @Rating;
    END;

CLOSE @cursor1;
DEALLOCATE @cursor1;
GO

-- 2 --
If OBJECT_ID(N'GetPlayerFullName', N'FN') IS NOT NULL
    BEGIN
        DROP FUNCTION GetPlayerFullName;
    END
GO

IF OBJECT_ID(N'GetPlayerCursorWithFullName', N'P') IS NOT NULL
    BEGIN
        DROP PROCEDURE GetPlayerCursorWithFullName;
    END
GO

CREATE FUNCTION dbo.GetPlayerFullName(
    @FirstName NVARCHAR(50),
    @MiddleName NVARCHAR(50),
    @LastName NVARCHAR(50)
)
    RETURNS NVARCHAR(101)
AS
BEGIN
    RETURN @FirstName + N' ' + @MiddleName + N' ' + @LastName;
END;
GO

CREATE PROCEDURE GetPlayerCursorWithFullName @cursor CURSOR VARYING OUTPUT,
                                             @minRating INT
AS
BEGIN
    SET @cursor = CURSOR FORWARD_ONLY STATIC FOR
        SELECT PlayerID,
               NickName,
               dbo.GetPlayerFullName(FirstName, MiddleName, LastName) AS FullName,
               BirthDate,
               Country,
               Rating
        FROM Player
        WHERE Rating >= @minRating
    OPEN @cursor
END
GO

-- 2.Test --
DECLARE @cursor1 CURSOR

DECLARE
    @PlayerID INT ,
    @NickName NVARCHAR(50) ,
    @FullName NVARCHAR(152),
    @BirthDate DATE,
    @Country NVARCHAR(56),
    @Rating INT;

EXECUTE GetPlayerCursorWithFullName @cursor = @cursor1 OUTPUT, @minRating = 100
FETCH NEXT FROM @cursor1 INTO
    @PlayerID, @NickName, @FullName, @BirthDate, @Country, @Rating

WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @PlayerID  AS PlayerID,
               @NickName  AS NickName,
               @FullName  AS FullName,
               @BirthDate AS BirthDate,
               @Country   AS Country,
               @Rating    AS Rating;
        FETCH NEXT FROM @cursor1 INTO
            @PlayerID, @NickName, @FullName, @BirthDate, @Country, @Rating;
    END;

CLOSE @cursor1;
DEALLOCATE @cursor1;
GO

-- 3 --
IF OBJECT_ID(N'IsPlayerFromCountry1', N'FN') IS NOT NULL
    BEGIN
        DROP FUNCTION IsPlayerFromCountry1;
    END
GO

IF OBJECT_ID(N'GetPlayerCursorFromCountry1', N'P') IS NOT NULL
    BEGIN
        DROP PROCEDURE GetPlayerCursorFromCountry1;
    END
GO

CREATE FUNCTION dbo.IsPlayerFromCountry1(
    @PlayerCountry NVARCHAR(56)
)
    RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @PlayerCountry = N'Country1' THEN 1 ELSE 0 END;
END;
GO

CREATE PROCEDURE GetPlayerCursorFromCountry1
AS
BEGIN
    DECLARE @cursor1 CURSOR

    DECLARE
        @PlayerID INT ,
        @NickName NVARCHAR(50) ,
        @FirstName NVARCHAR(50) ,
        @MiddleName NVARCHAR(50),
        @LastName NVARCHAR(50) ,
        @BirthDate DATE,
        @Country NVARCHAR(56),
        @Rating INT;

    EXECUTE GetPlayersCursor @cursor = @cursor1 OUTPUT, @minRating = 100

    FETCH NEXT FROM @cursor1 INTO
        @PlayerID, @NickName, @FirstName, @MiddleName, @LastName, @BirthDate, @Country, @Rating
    PRINT 'Players who from Country1:';
    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF dbo.IsPlayerFromCountry1(@Country) = 1
                BEGIN
                    SELECT @PlayerID   AS PlayerID,
                           @NickName   AS NickName,
                           @FirstName  AS FirstName,
                           @MiddleName AS MiddleName,
                           @LastName   AS LastName,
                           @BirthDate  AS BirthDate,
                           @Country    AS Country,
                           @Rating     AS Rating;
                END
            FETCH NEXT FROM @cursor1 INTO
                @PlayerID, @NickName, @FirstName, @MiddleName, @LastName, @BirthDate, @Country, @Rating;
        END;

    CLOSE @cursor1;
    DEALLOCATE @cursor1;
END
GO

-- 3.Test --

EXECUTE GetPlayerCursorFromCountry1;
GO

-- 4 --
IF OBJECT_ID(N'GetTablePlayersWithFullName', N'IF') IS NOT NULL
    DROP FUNCTION GetTablePlayersWithFullName;
GO

IF OBJECT_ID(N'UseGetTablePlayersWithFullName', N'P') IS NOT NULL
    DROP PROCEDURE UseGetTablePlayersWithFullName;
GO

-- inline --
CREATE FUNCTION dbo.GetTablePlayersWithFullName(
    @minRating INT
)
    RETURNS TABLE
        AS
        RETURN(SELECT PlayerID,
                      NickName,
                      dbo.GetPlayerFullName(FirstName, MiddleName, LastName) AS FullName,
                      BirthDate,
                      Country,
                      Rating
               FROM Player
               WHERE Rating >= @minRating);
GO

-- not-inline --
/*
CREATE FUNCTION dbo.GetTablePlayersWithFullName(
    @minRating INT
    )
        RETURNS @ResTable TABLE(
        PlayerID   INT,
        NickName   NVARCHAR(50),
        FullName   NVARCHAR(50),
        BirthDate  DATE,
        Country    NVARCHAR(56),
        Rating     INT ,
    )
AS
    BEGIN
        INSERT INTO @Result
        SELECT
            PlayerID,
               NickName,
               dbo.GetPlayerFullName(FirstName, MiddleName, LastName) AS FullName,
               BirthDate,
               Country,
               Rating
        FROM Player
        WHERE Rating >= @minRating
        RETURN;
    END
GO
 */

CREATE PROCEDURE UseGetTablePlayersWithFullName
AS
    BEGIN
        SELECT * FROM dbo.GetTablePlayersWithFullName(100)
    END
GO

-- 4.Test --
EXECUTE UseGetTablePlayersWithFullName;
GO

