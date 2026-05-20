# Lesson 07 – Exercises: Subqueries

Use the `music` database for all exercises.

The exercises use the `MusicGroup`, `Album`, and `Artist` tables:

**MusicGroup**

| Column | Type | Description |
|---|---|---|
| `MusicGroupId` | `uniqueidentifier` | Primary key |
| `Name` | `varchar` | Group name |
| `EstablishedYear` | `int` | Year the group was formed |
| `Genre` | `varchar` | `'Rock'`, `'Blues'`, `'Jazz'`, `'Metal'` |

**Album**

| Column | Type | Description |
|---|---|---|
| `AlbumId` | `uniqueidentifier` | Primary key |
| `Name` | `varchar` | Album title |
| `ReleaseYear` | `int` | Year the album was released |
| `CopiesSold` | `bigint` | Total copies sold |
| `MusicGroupId` | `uniqueidentifier` | Foreign key to `MusicGroup` |

**Artist**

| Column | Type | Description |
|---|---|---|
| `ArtistId` | `uniqueidentifier` | Primary key |
| `FirstName` | `varchar` | Artist's first name |
| `LastName` | `varchar` | Artist's last name |
| `BirthDay` | `datetime` | Date of birth — **nullable** |

---

## Exercise 1 – Scalar Subquery

**Task:** Write **two queries** against the `music` database using a scalar subquery in the `WHERE` clause.

**Query 1:** List all albums where `CopiesSold` **equals** the maximum `CopiesSold` of any album in the catalog (i.e. find the best-selling album(s)).

Return `Name` and `CopiesSold`. The subquery must supply the maximum value — do **not** hard-code a number.

**Query 2:** List all albums where `CopiesSold` is **less than** the maximum `CopiesSold` (all albums except the best-selling one).

Return `Name` and `CopiesSold`, ordered by `CopiesSold` descending.

**Hint:** A scalar subquery returns exactly one value. Use `(SELECT MAX(CopiesSold) FROM dbo.Album)` as the right-hand side of a `=` or `<` comparison. Write and test the inner query on its own first.

**Expected outcome:**
- Query 1: one or more rows showing the album(s) with the highest copies sold.
- Query 2: all other albums ordered from most to least copies sold.

**Answer:** [01-subquery.sql](../exercise-answers/01-subquery.sql)

---

## Exercise 2 – IN Subquery

**Task:** Write a query that lists all albums belonging to music groups in the **Rock or Blues** genre.

Use a subquery in the `WHERE` clause with `IN` to first retrieve the `MusicGroupId` values of all Rock and Blues groups, then return their albums.

Return `Name` (album title) and `ReleaseYear`, ordered by `ReleaseYear` ascending.

**Hint:** The inner query targets `dbo.MusicGroup` and filters on `Genre IN ('Rock', 'Blues')`. The outer query targets `dbo.Album`. Write and verify the inner query on its own before embedding it.

**Expected outcome:** All albums whose owning music group has a genre of Rock (0) or Blues (1), ordered by release year.

**Answer:** [01-subquery.sql](../exercise-answers/01-subquery.sql)

---

## Exercise 3 – IN / NOT IN with NULL Awareness

**Task:** Write **three queries** that explore which album release years overlap with artist birth years. The `BirthDay` column is **nullable** — this is important for the `NOT IN` queries.

**Query 1:** List all albums whose `ReleaseYear` matches a year in which **at least one artist was born**.  
Use `IN` with a subquery that extracts `DISTINCT YEAR(BirthDay)` from `dbo.Artist`.  
Return `Name` and `ReleaseYear`.

**Query 2:** List all albums whose `ReleaseYear` does **not** appear in the birth years of any artist.  
Use `NOT IN` with the **same subquery as Query 1** (no NULL filter).  
Return `Name` and `ReleaseYear`. Observe the result — does it behave as expected?

**Query 3:** Repeat Query 2, but this time add `WHERE BirthDay IS NOT NULL` inside the subquery to exclude NULL birth years.  
Return `Name` and `ReleaseYear`. Compare the result with Query 2.

**Hint:** `NOT IN` returns no rows when the subquery result set contains even one `NULL` value, because SQL cannot confirm that the outer value is "not equal to NULL". Adding `WHERE BirthDay IS NOT NULL` inside the subquery fixes this.

**Expected outcome:**
- Query 1: albums released in years when at least one artist was born.
- Query 2: likely returns no rows due to the NULL in the subquery.
- Query 3: albums released in years when no artist was born (correct result after removing NULLs).

**Answer:** [01-subquery.sql](../exercise-answers/01-subquery.sql)

---

## Exercise 4 – Nested Subquery

**Task:** Write a **single SQL query** that lists all music groups belonging to the **genre with the highest total copies sold** across all its albums.

Break the problem down before writing the final query:

1. Write a query that calculates **total copies sold per genre** (join `Album` → `MusicGroup`, `GROUP BY Genre`).
2. Extend it to return only the **top 1 genre** by total copies sold (`TOP 1 … ORDER BY … DESC`).
3. Isolate just the `Genre` value from step 2 by wrapping it as a derived table (inline subquery in `FROM`).
4. Use the result of step 3 as a subquery in a `WHERE Genre = (…)` clause against `dbo.MusicGroup`.

Return `Name` and `EstablishedYear` of the matching music groups, ordered by `EstablishedYear` ascending.

**Hint:** A derived table is a subquery used in the `FROM` clause and must be given an alias. Your final query will contain a subquery nested inside another subquery.

**Expected outcome:** All music groups in the single genre that has generated the most combined copies sold, ordered by the year they were established.

**Answer:** [01-subquery.sql](../exercise-answers/01-subquery.sql)

---

## Exercise 5 – Nested Subquery: City with the Most Friends

Use the `friends` database.

The exercise uses the `Friend` and `Address` tables:

**Friend**

| Column | Type | Description |
|---|---|---|
| `FriendId` | `uniqueidentifier` | Primary key |
| `FirstName` | `nvarchar` | Friend's first name |
| `LastName` | `nvarchar` | Friend's last name |
| `AddressId` | `uniqueidentifier` | Foreign key to `Address` |

**Address**

| Column | Type | Description |
|---|---|---|
| `AddressId` | `uniqueidentifier` | Primary key |
| `City` | `nvarchar` | City name |
| `Country` | `nvarchar` | Country name |

---

**Task:** Write a **single SQL query** that lists all friends living in the **city with the most friends**.

Break the problem down before writing the final query:

1. Write a query that counts how many friends live in each city (join `Friend` → `Address`, `GROUP BY City`).
2. Extend it to return only the **top 1 city** by friend count (`TOP 1 … ORDER BY … DESC`).
3. Isolate just the `City` value from step 2 by wrapping it as a derived table.
4. Use the result of step 3 as a scalar subquery in a `WHERE City = (…)` clause against the outer query joining `Friend` and `Address`.

Return `FirstName`, `LastName`, and `City` of the matching friends.

**Hint:** Follow the same four-step pattern as Exercise 4. The derived table in step 3 wraps the `TOP 1` query and must be given an alias. Your final query will contain a subquery nested inside another subquery.

**Expected outcome:** All friends whose address city is the single city that has the highest number of friends living in it.

**Answer:** [01-subquery.sql](../exercise-answers/01-subquery.sql)

---

## Exercise 6 – Nested Subquery: Pets of the Most Common Kind

Use the `friends` database.

The exercise uses the `Friend` and `Pet` tables:

**Pet**

| Column | Type | Description |
|---|---|---|
| `PetId` | `uniqueidentifier` | Primary key |
| `AnimalKind` | `nvarchar` | Animal type (e.g. `'Dog'`, `'Cat'`, `'Rabbit'`) |
| `Name` | `nvarchar` | Pet's name |
| `OwnerId` | `uniqueidentifier` | Foreign key to `Friend` |

---

**Task:** Write a **single SQL query** that lists all pets (with their owner's full name) whose `AnimalKind` is the **most common animal type** in the database.

Break the problem down before writing the final query:

1. Write a query that counts pets per `AnimalKind` (`GROUP BY AnimalKind`).
2. Extend it to return only the **top 1 kind** by count (`TOP 1 … ORDER BY … DESC`).
3. Isolate just the `AnimalKind` value from step 2 by wrapping it as a derived table.
4. Use the result of step 3 as a scalar subquery in a `WHERE AnimalKind = (…)` clause. Join `Pet` → `Friend` to include the owner's name.

Return `Pet.Name` as `PetName`, `AnimalKind`, and the owner's full name as `OwnerName` (use `CONCAT_WS`), ordered by `OwnerName` ascending.

**Hint:** The structure mirrors Exercises 4 and 5. Write and verify each step independently, then nest them into a single query.

**Expected outcome:** All pets whose type is the single most frequently occurring `AnimalKind`, together with the full name of each pet's owner.
