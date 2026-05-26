USE [music];
GO

--create a schema that I will assign permissons to role
CREATE SCHEMA usr;
GO

--create usr. views from the dbo. tables
CREATE VIEW usr.vwMusicGroups AS
SELECT [Name] FROM dbo.MusicGroup;
GO

CREATE VIEW usr.vwAlbums AS
SELECT [Name] FROM dbo.Album;
GO

CREATE VIEW usr.vwArtists AS
SELECT [FirstName], [LastName] FROM dbo.Artist;
GO


--Create a role for common users
CREATE ROLE musicUsers;


CREATE USER AlbusUser WITHOUT LOGIN;
ALTER ROLE musicUsers ADD MEMBER AlbusUser;

--SELECT only rights to Role musicUsers to everything in SCHEMA usr
GRANT SELECT ON SCHEMA::usr to musicUsers;

EXECUTE AS USER = 'AlbusUser';

SELECT * FROM dbo.Artist;
SELECT * FROM usr.vwArtists;

REVERT;

