# Lesson 12 – Exercises: Scalar and Table-Valued Functions

Exercises 1 and 2 use the `music` database. Exercises 3 and 4 use the `friends` database.

### Music database tables (exercises 1–2)

**Artist**

| Column | Type | Description |
|---|---|---|
| `ArtistId` | `uniqueidentifier` | Primary key |
| `FirstName` | `nvarchar` | First name |
| `LastName` | `nvarchar` | Last name |
| `BirthDay` | `datetime` | Date of birth — **nullable** |

**MusicGroup**

| Column | Type | Description |
|---|---|---|
| `MusicGroupId` | `uniqueidentifier` | Primary key |
| `Name` | `nvarchar` | Group name |
| `EstablishedYear` | `int` | Year the group was formed |
| `Genre` | `nvarchar` | `'Rock'`, `'Blues'`, `'Jazz'`, `'Metal'` |

**Album**

| Column | Type | Description |
|---|---|---|
| `AlbumId` | `uniqueidentifier` | Primary key |
| `Name` | `nvarchar` | Album title |
| `ReleaseYear` | `int` | Year the album was released |
| `CopiesSold` | `bigint` | Total copies sold |
| `MusicGroupId` | `uniqueidentifier` | Foreign key to `MusicGroup` |

### Friends database tables (exercises 3–4)

**Friend**

| Column | Type | Description |
|---|---|---|
| `FriendId` | `uniqueidentifier` | Primary key |
| `FirstName` | `nvarchar` | First name |
| `LastName` | `nvarchar` | Last name |
| `Email` | `nvarchar` | Email address |
| `Birthday` | `datetime` | Date of birth — **nullable** |
| `AddressId` | `uniqueidentifier` | Foreign key to `Address` |

**Address**

| Column | Type | Description |
|---|---|---|
| `AddressId` | `uniqueidentifier` | Primary key |
| `StreetAddress` | `nvarchar` | Street address |
| `ZipCode` | `int` | Postal code |
| `City` | `nvarchar` | City name |
| `Country` | `nvarchar` | Country name |

**Pet**

| Column | Type | Description |
|---|---|---|
| `PetId` | `uniqueidentifier` | Primary key |
| `OwnerId` | `uniqueidentifier` | Foreign key to `Friend` |
| `Name` | `nvarchar` | Pet name |
| `AnimalKind` | `nvarchar` | `'Dog'`, `'Cat'`, `'Rabbit'`, `'Fish'`, `'Bird'` |
| `AnimalMood` | `nvarchar` | `'Happy'`, `'Hungry'`, `'Lazy'`, `'Sulky'`, `'Buzy'`, `'Sleepy'` |

---

## Exercise 1 – Scalar Function: Formatted Initials

**Database:** `music`

**Concepts:** `CREATE FUNCTION`, `RETURNS` scalar value, `BEGIN...END`, string functions, calling a UDF in a `SELECT`.

**Task:** Create a scalar function `dbo.udf_ArtistInitials` that takes `@FirstName NVARCHAR(200)` and `@LastName NVARCHAR(200)` and returns the name formatted as the **first letter of the first name, a period, and the full last name** — for example `"J. Smith"`.

Use `LEFT()` to extract the first initial and `CONCAT()` to assemble the result.

Then write a `SELECT` against `dbo.Artist` that returns:

- `dbo.udf_ArtistInitials(FirstName, LastName)` aliased as `ShortName`
- `BirthDay`

Order the results by `LastName`.

**Hint:** Inside the function body: `RETURN CONCAT(LEFT(@FirstName, 1), '. ', @LastName)`. Remember to `DROP FUNCTION IF EXISTS` before `CREATE`.

**Expected outcome:** One row per artist showing their formatted short name and birthday, ordered alphabetically by last name.

**Answer:** [01-functions.sql](../exercise-answers/01-functions.sql)

---

## Exercise 2 – Scalar Function: Group Era (Conditional Logic)

**Database:** `music`

**Concepts:** `CREATE OR ALTER FUNCTION`, `DECLARE`, `IF`/`ELSE IF` branching, returning a computed label.

**Task:** Create a scalar function `dbo.udf_GroupEra` that takes `@EstablishedYear INT` and returns an `NVARCHAR(20)` era label:

| Condition | Return value |
|---|---|
| Year < 1980 | `'Classic'` |
| Year 1980 – 1999 | `'Golden Age'` |
| Year ≥ 2000 | `'Modern'` |

Inside the function:
- `DECLARE` an `@Era NVARCHAR(20)` variable.
- Use `IF`/`ELSE IF` blocks to set `@Era`.
- `RETURN @Era` as the final statement.

Then write a `SELECT` against `dbo.MusicGroup` that returns `Name`, `Genre`, `EstablishedYear`, and `dbo.udf_GroupEra(EstablishedYear)` aliased as `Era`, ordered by `EstablishedYear`.

**Hint:** There is no `NULL` check needed here — `EstablishedYear` is not nullable. The structure mirrors the conditional pattern in the scripts: `DECLARE`, then `IF`/`ELSE IF`, then `RETURN`.

**Expected outcome:** One row per music group showing its name, genre, founding year, and era label, ordered from oldest to newest.

**Answer:** [01-functions.sql](../exercise-answers/01-functions.sql)

---

## Exercise 3 – Table-Valued Function: Friends by Country

**Concepts:** Inline table-valued function, `RETURNS TABLE AS RETURN`, parameterised TVF, calling a TVF in a `FROM` clause, using a TVF result as a subquery.

**Task:** Create an inline TVF `dbo.udf_FriendsByCountry` that accepts `@Country NVARCHAR(100)` and returns `FriendId`, `FirstName`, `LastName`, `Email`, and `City` for all friends living in that country, by joining `dbo.Friend` to `dbo.Address`.

Then write **two** queries:

1. Call the function directly to list `FirstName`, `LastName`, `Email`, and `City` for all friends in `'Sweden'`.
2. Use the function as a subquery to find all pets (`Pet.Name` aliased as `PetName`, `AnimalKind`) owned by friends from `'USA'` — query `dbo.Pet` where `OwnerId IN (SELECT FriendId FROM dbo.udf_FriendsByCountry('USA'))`.

**Hint:** The TVF body joins: `dbo.Friend AS f INNER JOIN dbo.Address AS a ON f.AddressId = a.AddressId WHERE a.Country = @Country`. Include `f.FriendId` in the select list so the subquery in part 2 can reference it.

**Expected outcome:**
1. A list of friends living in the specified country with their city and email.
2. The names and kinds of all pets owned by friends from that country.

**Answer:** [01-functions.sql](../exercise-answers/01-functions.sql)

---

## Exercise 4 – Table-Valued Functions: UNION of Two TVFs

**Concepts:** Multiple TVFs with no parameters, `GROUP BY` / `HAVING` inside a TVF, `UNION`, `SELECT DISTINCT` across combined TVF results.

**Task:** Create two inline TVFs (both take no parameters):

1. **`dbo.udf_HappyPetOwners`** — Returns `FirstName`, `LastName`, and `Country` for every friend who owns at least one pet with `AnimalMood = 'Happy'`. Join `Friend`, `Pet`, and `Address`.

2. **`dbo.udf_MultiplePetOwners`** — Returns `FirstName`, `LastName`, and `Country` for every friend who owns **more than one** pet. Join `Friend`, `Pet`, and `Address`. Group by `FriendId`, `FirstName`, `LastName`, and `Country`, using `HAVING COUNT(p.PetId) > 1`.

Then write a `SELECT DISTINCT` that `UNION`s both TVF results to produce a deduplicated list of friends who satisfy **either** condition. Return `FirstName`, `LastName`, and `Country`, ordered by `LastName`.

**Hint:** Wrap both `SELECT ... FROM dbo.udf_...()` calls inside a derived table and select from it, or simply `UNION` them inside a `FROM (... UNION ...) AS combined` clause. Follow the same pattern used in the scripts where two TVF results are combined with `UNION` inside an `IN` clause.

**Expected outcome:** A deduplicated list of friends who are happy-pet owners or own more than one pet, ordered by last name.

**Answer:** [01-functions.sql](../exercise-answers/01-functions.sql)
