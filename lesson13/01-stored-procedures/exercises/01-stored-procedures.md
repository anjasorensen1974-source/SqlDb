# Lesson 13 – Exercises: Stored Procedures

Exercises 1 and 4 use the `music` database. Exercise 2 uses the `friends` database. Exercise 3 uses the `sakila` database.

### Music database tables (exercises 1, 4)

| Table | Key columns |
|---|---|
| `MusicGroup` | `MusicGroupId`, `Name`, `EstablishedYear`, `Genre` (`'Rock'`,`'Blues'`,`'Jazz'`,`'Metal'`) |
| `Album` | `AlbumId`, `Name`, `ReleaseYear`, `CopiesSold`, `MusicGroupId` |
| `Artist` | `ArtistId`, `FirstName`, `LastName`, `BirthDay` |
| `ArtistMusicGroup` | `ArtistId`, `MusicGroupId` |

### Friends database tables (exercise 2)

| Table | Key columns |
|---|---|
| `Friend` | `FriendId`, `FirstName`, `LastName`, `Email`, `Birthday`, `AddressId` |
| `Address` | `AddressId`, `StreetAddress`, `ZipCode`, `City`, `Country` |
| `Pet` | `PetId`, `OwnerId` (→`Friend`), `Name`, `AnimalKind`, `AnimalMood` |

### Sakila database tables (exercise 3)

| Table | Key columns |
|---|---|
| `film` | `film_id`, `title`, `rating`, `rental_rate`, `length` |
| `inventory` | `inventory_id`, `film_id` |
| `rental` | `rental_id`, `inventory_id` |

---

## Exercise 1 – Basic Stored Procedure with Input Parameters and Return Code

**Database:** `music`

**Concepts:** `CREATE OR ALTER PROCEDURE`, `SET NOCOUNT ON`, required input parameters, `RETURN 0`, capturing the return code, conditional `PRINT`.

**Task:** Create a stored procedure `dbo.usp_GetAlbumsByGenre` that accepts two required parameters:

- `@Genre NVARCHAR(50)` — the music genre to filter on
- `@MinCopiesSold BIGINT` — the minimum number of copies sold

The procedure should:
1. Use `SET NOCOUNT ON`.
2. Return `GroupName` (from `MusicGroup.Name`), `AlbumName` (from `Album.Name`), `ReleaseYear`, and `CopiesSold` by joining `dbo.Album` to `dbo.MusicGroup`.
3. Filter results where `Genre = @Genre` and `CopiesSold >= @MinCopiesSold`, ordered by `CopiesSold` descending.
4. End with `RETURN 0` to signal success.

Then execute the procedure:
- Declare an `@ret INT` variable.
- Execute the procedure with `EXEC @ret = dbo.usp_GetAlbumsByGenre 'Rock', 1000000`.
- After the `EXEC`, use `IF @ret = 0` to `PRINT 'Procedure executed successfully'`, otherwise `PRINT 'Error executing stored procedure'`.

**Hint:** Put `RETURN 0` as the last statement before `GO`. Capture the return code with `DECLARE @ret INT; EXEC @ret = dbo.usp_GetAlbumsByGenre ...` — notice the return code is captured on the `EXEC` line itself, not as an `OUTPUT` parameter.

**Expected outcome:** A result set of Rock albums that have sold at least 1 million copies, ordered from best-selling to least-selling, followed by the success message in the Messages tab.

**Answer:** [01-stored-procedures.sql](../exercise-answers/01-stored-procedures.sql)

---

## Exercise 2 – Default Parameters and OUTPUT Parameter

**Database:** `friends`

**Concepts:** Default `NULL` parameter values, the `IS NULL OR` filter pattern, `OUTPUT` parameters, `@@ROWCOUNT`, named-parameter execution.

**Task:** Create a stored procedure `dbo.usp_GetPetsByMood` with the following signature:

```sql
dbo.usp_GetPetsByMood
    @AnimalMood  NVARCHAR(20) = NULL,
    @AnimalKind  NVARCHAR(20) = NULL,
    @PetCount    INT OUTPUT
```

The procedure should:
1. Join `dbo.Friend` to `dbo.Pet` and return `FirstName`, `LastName`, `Pet.Name` (aliased `PetName`), `AnimalKind`, and `AnimalMood`.
2. Apply the nullable filter pattern: `(@AnimalMood IS NULL OR p.AnimalMood = @AnimalMood) AND (@AnimalKind IS NULL OR p.AnimalKind = @AnimalKind)`.
3. Set `@PetCount = @@ROWCOUNT` immediately after the `SELECT`.
4. End with `RETURN 0`.

Then write four `EXEC` calls demonstrating different parameter combinations:
1. No arguments — returns all pets.
2. `@AnimalMood = 'Happy'` only (named parameter style).
3. `@AnimalKind = 'Fish'` only (named parameter style).
4. Both `@AnimalMood = 'Happy'` and `@AnimalKind = 'Fish'`.

For each call, `PRINT` a message like `'Happy pets: 5'` using the captured `@PetCount`.

**Hint:** Declare `@count INT` and `@ret INT` before the first `EXEC`. Pass `@PetCount = @count OUTPUT` in each call. To use named parameters, write `EXEC dbo.usp_GetPetsByMood @AnimalMood = 'Happy', @PetCount = @count OUTPUT`.

**Expected outcome:** Four separate result sets, each followed by a printed count in the Messages tab, showing how the same procedure behaves differently based on which filters are supplied.

**Answer:** [01-stored-procedures.sql](../exercise-answers/01-stored-procedures.sql)

---

## Exercise 3 – Stored Procedure with CTE, Result Captured into Temp Table and Table Variable

**Database:** `sakila`

**Concepts:** CTE inside a stored procedure, `CREATE TABLE #tmpTable`, `INSERT INTO #tmpTable EXEC`, `DECLARE @tableVar TABLE`, capturing SP output for further querying.

**Task:** Create a stored procedure `dbo.usp_TopRentedFilms` that accepts:

- `@rating NVARCHAR(10)` — the film rating to filter on (e.g. `'PG'`, `'PG-13'`)
- `@top_n INT` — how many films to return

Inside the procedure, use a **CTE** named `film_rentals` that:
- Selects `film_id`, `title`, `rating`, and `COUNT(rental_id)` aliased as `rental_count` from `film`.
- Joins `film` → `inventory` → `rental`.
- Filters on `film.rating = @rating`.
- Groups by `film_id`, `title`, `rating`.

The outer `SELECT` should use `TOP (@top_n)` against the CTE, returning `title`, `rating`, and `rental_count`, ordered by `rental_count` descending.

After creating the procedure, demonstrate capturing its result set in **two** ways:
1. A **temp table** `#topFilms(title, rating, rental_count)` — use `INSERT INTO #topFilms EXEC dbo.usp_TopRentedFilms 'PG', 10`, then `SELECT * FROM #topFilms`.
2. A **table variable** `@topFilms` with the same structure — use `INSERT INTO @topFilms EXEC dbo.usp_TopRentedFilms 'PG-13', 5`, then `SELECT * FROM @topFilms`.

**Hint:** Declare the CTE with `;WITH film_rentals AS (...)` at the start of the procedure body. The `TOP (@top_n)` syntax accepts a variable when wrapped in parentheses. Drop `#topFilms` with `DROP TABLE IF EXISTS #topFilms` at the end.

**Expected outcome:** Two result sets — the first showing the top 10 most-rented PG films, the second showing the top 5 most-rented PG-13 films — demonstrating that the same procedure output can be consumed in different ways.

**Answer:** [01-stored-procedures.sql](../exercise-answers/01-stored-procedures.sql)

---

## Exercise 4 – Stored Procedure with WHILE Loop and Temp Table

**Database:** `music`

**Concepts:** `CREATE TABLE` inside a procedure, `DECLARE` and `SET`, `WHILE ... BEGIN ... END` loop, `INSERT` inside a loop, `SELECT` from a temp table.

**Task:** Create a stored procedure `dbo.usp_AlbumsByDecade` (no parameters) that summarises album data by decade.

Inside the procedure:
1. Create a temp table `#decades` with columns `Decade NVARCHAR(10)`, `AlbumCount INT`, and `TotalCopiesSold BIGINT`.
2. Declare an `@decade INT` variable and initialise it to `1950`.
3. Use a `WHILE @decade <= 2020` loop. In each iteration:
   - `INSERT INTO #decades` a single row: the decade label (e.g. `'1950s'`), the count of albums with `ReleaseYear BETWEEN @decade AND @decade + 9`, and the sum of their `CopiesSold` (use `ISNULL(SUM(...), 0)` to handle decades with no albums).
   - Increment `@decade` by `10`.
4. After the loop, `SELECT * FROM #decades WHERE AlbumCount > 0`.

**Hint:** Build the decade label using `CAST(@decade AS NVARCHAR(4)) + 's'`. The `INSERT INTO #decades SELECT ...` pattern lets you insert a computed aggregate row in one statement — no need for a separate variable per row.

**Expected outcome:** One row per decade that has at least one album in the database, showing the decade label, number of albums released in that decade, and total copies sold.

**Answer:** [01-stored-procedures.sql](../exercise-answers/01-stored-procedures.sql)
