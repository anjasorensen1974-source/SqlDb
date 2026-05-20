USE music;
GO

-- ============================================================
-- Exercise 2 – Load data from a JSON file
-- ============================================================

-- Preparations: copy the json file into the Docker container
--   1. Open a terminal in the directory of your json files on the computer
--   2. Create a directory in the Docker container:
--         docker exec -u root sql2022container mkdir /usr/jsonfiles
--   3. Copy the json file from your computer into the Docker container:
--         docker cp json-music-example.json sql2022container:/usr/jsonfiles/

-- Load the JSON file into a temp table using SELECT INTO
SELECT album.*
INTO #fromJSON
FROM
-- SINGLE_CLOB reads the file as a character string (unlike XML which uses SINGLE_BLOB)
OPENROWSET(BULK N'/usr/jsonfiles/json-music-example.json', SINGLE_CLOB) AS json
-- OPENJSON with WITH clause parses the JSON array and maps properties to typed columns
CROSS APPLY OPENJSON(BulkColumn)
WITH (
    AlbumId     UNIQUEIDENTIFIER,
    Name        NVARCHAR(200),
    ReleaseYear INT,
    Genre       NVARCHAR(200)
) AS album;

SELECT * FROM #fromJSON;

-- 1. Create a working copy of Album to safely test the update
SELECT * INTO #tmpAlbum FROM dbo.Album;
SELECT * FROM #tmpAlbum;

-- 2. Update the copy with Name values from the JSON data
UPDATE ta
    SET ta.Name = js.Name
FROM #tmpAlbum ta
INNER JOIN #fromJSON js ON ta.AlbumId = js.AlbumId;

-- 3. Verify the result
SELECT * FROM #tmpAlbum;

DROP TABLE #fromJSON;
DROP TABLE #tmpAlbum;

-- Cleanup: remove the json files from the Docker container
--   1. Open a terminal
--   2. Remove the json files:
--         docker exec -u root sql2022container rm -rf /usr/jsonfiles
