USE [sql-music];
GO

--create a schema that I will assign permissons to role
CREATE SCHEMA usr;
GO

--create usr. views from the dbo. tables
CREATE VIEW usr.vwMusicGroups AS
SELECT [Name] FROM dbo.MusicGroups;
GO

CREATE VIEW usr.vwAlbums AS
SELECT [Name] FROM dbo.Albums;
GO

CREATE VIEW usr.vwArtists AS
SELECT [FirstName], [LastName] FROM dbo.Artists;
GO



--Create a role for common users
--CREATE ROLE musicUsers;

DENY SELECT ON dbo.Albums to musicUsers;
DENY SELECT ON dbo.Artists to musicUsers;
DENY SELECT ON dbo.MusicGroups to musicUsers;

--SELECT only rights to Role musicUsers to everything in SCHEMA usr
GRANT SELECT, EXECUTE ON SCHEMA::usr to musicUsers;

EXECUTE AS USER = 'Albus';

SELECT * FROM dbo.Artists;
SELECT * FROM usr.vwArtists;

REVERT;

