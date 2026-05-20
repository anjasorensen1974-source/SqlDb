# Lesson 05 – Exercise 03: JSON

> **Database:** `sakila`
>
> | Table | Key columns |
> |---|---|
> | `film` | `film_id`, `title`, `description`, `release_year`, `rental_rate`, `rating` |
> | `actor` | `actor_id`, `first_name`, `last_name` |
> | `film_actor` | `film_id`, `actor_id` |

---

## Exercise 1 – Output query results as JSON

**Task:**  
Write a query that joins `film`, `film_actor`, and `actor` to retrieve the top 5 films with their actors. Select `film_id`, `title`, `release_year`, `rating` from `film`, and `first_name`, `last_name` from `actor`. Output the results using `FOR JSON PATH`.  
Store the result in a variable of type `NVARCHAR(MAX)` and then `SELECT` the variable to inspect the JSON string.

**Hint:**  
`FOR JSON PATH` goes at the end of the `SELECT` statement. Wrap the whole query in parentheses when assigning it to a variable, e.g. `SET @json = (SELECT ... FOR JSON PATH)`.

**Expected outcome:**  
A JSON string containing 5 film objects, each with nested actor properties. Selecting the variable should display the raw JSON.

**Answer:** [03-json.sql](../exercise-answers/03-json.sql)

---

## Exercise 2 – Load data from a JSON file

**Task:** You have been provided with a JSON file `json-music-example.json` containing album records. Load its contents into a temporary table `#fromJSON` with the following columns:

| Column | JSON property |
|---|---|
| `AlbumId` | `AlbumId` |
| `Name` | `Name` |
| `ReleaseYear` | `ReleaseYear` |
| `Genre` | `Genre` |

Then use the loaded data to update the `Name` column in a copy of the `Album` table.

Steps to complete:

1. Copy the JSON file into the Docker container:
   ```
   docker exec -u root sql2022container mkdir /usr/jsonfiles
   docker cp json-music-example.json sql2022container:/usr/jsonfiles/
   ```
2. Use `OPENROWSET(BULK ..., SINGLE_CLOB)` to read the file.
3. Use `CROSS APPLY OPENJSON(BulkColumn) WITH (...)` to parse the JSON array into rows, declaring each column with its type.
4. Use `SELECT ... INTO #fromJSON` to capture the result in a temp table.
5. Create a working copy of `Album` with `SELECT * INTO #tmpAlbum FROM Album`.
6. Join `#tmpAlbum` to `#fromJSON` on `AlbumId` and `UPDATE` the `Name` column.
7. `SELECT` from both tables to verify the result.
8. `DROP TABLE #fromJSON` and `DROP TABLE #tmpAlbum` to clean up.

**Hint:** Unlike XML, JSON is loaded with `SINGLE_CLOB` (character, not binary). `OPENJSON` with a `WITH` clause lets you declare the target columns and types directly — no separate `UPDATE` for whitespace needed.

**Answer:** [04-json.sql](../exercise-answers/04-json.sql)
