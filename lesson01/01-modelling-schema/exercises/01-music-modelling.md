# Lesson 01 – Exercises: Creating a Music Database with SQL Scripts from C# Models

These exercises mirror what was done in Lesson 01 for the `friends` database, but using the music domain models found in `CSharp-models/music/`. Model relationship properties are intentionally excluded.

---

## Reference: C# Models (properties only)

### `Artist.cs`
```csharp
public Guid ArtistId { get; set; }
public string FirstName { get; set; }
public string LastName { get; set; }
public DateTime? BirthDay { get; set; }
```

### `MusicGroup.cs`
```csharp
public enum MusicGenre { Rock, Blues, Jazz, Metal }

public Guid MusicGroupId { get; set; }
public string Name { get; set; }
public int EstablishedYear { get; set; }
public MusicGenre Genre { get; set; }
```

### `Album.cs`
```csharp
public Guid AlbumId { get; set; }
public string Name { get; set; }
public int ReleaseYear { get; set; }
public long CopiesSold { get; set; }
```

---

## C# to T-SQL Type Reference

Use this table as a guide when writing your `CREATE TABLE` statements.

| C# Type | T-SQL Type | Notes |
|---|---|---|
| `Guid` | `uniqueidentifier` | Add `NOT NULL DEFAULT NEWID()` so the database generates the key automatically |
| `string` | `nvarchar(n)` | Choose a sensible `n` for the column's expected content (e.g. `100` for names, `200` for longer text) |
| `int` | `int` | Direct equivalent — 32-bit signed integer |
| `long` | `bigint` | 64-bit signed integer; use when values may exceed ~2 billion |
| `DateTime?` | `date` | The `?` means nullable in C#, so allow `NULL` in SQL. Use `date` when only the calendar date is needed, not time |
| `enum` | `nvarchar(n)` | SQL Server has no enum type; store the member name as a string so data stays human-readable |

---

## Exercise 1 – Create the Database

**Task:** Write a script that creates a new database called `music`. Remember to switch to a safe context first so you are not connected to a database that may conflict with the operation.


**Hints:**
- Look at how `01-create-database.sql` switches context before issuing `CREATE DATABASE`.
- Use `GO` to separate each batch.

**Suggested solution:** [01-create-database.sql](../01-exercise-answers/01-create-database.sql)
-- Växla till master-databasen för att säkerställa en säker kontext
USE master;
GO

-- Kontrollera om databasen redan finns och ta bort den om så önskas 
-- (Valfritt, men bra för skript som ska kunna köras flera gånger)
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'music')
BEGIN
DROP DATABASE music;
END
GO

CREATE DATABASE music;
GO

USE music;
GO
---

## Exercise 2 – Create a Drop-Database Script

**Task:** Write a companion cleanup script that drops the `music` database so you can reset and rerun your creation scripts during development.

**Hints:**
- You must not be connected to the database you want to drop.
- Look at `01a-drop-database.sql` for the pattern.

**Suggested solution:** [01a-drop-database.sql](../01-exercise-answers/01a-drop-database.sql)

---

## Exercise 3 – Create the `Artist` Table

**Task:** Write a `CREATE TABLE` statement for the `Artist` model inside the `music` database. Include the two session settings used in Lesson 01 before the `CREATE TABLE`.

**Types to map:**
- `ArtistId` — `Guid`
- `FirstName`, `LastName` — `string`
- `BirthDay` — `DateTime?`

**Hints:**
- The `?` on `DateTime?` means the value can be absent — reflect that with `NULL` in SQL.
- Choose `date` rather than `datetime` because only a birthdate (no time) is needed.
- All columns other than the primary key can be `NULL`.

**Suggested solution:** [01b-create-Artist.sql](../01-exercise-answers/01b-create-Artist.sql)

---

## Exercise 4 – Create the `MusicGroup` Table

**Task:** Write a `CREATE TABLE` statement for the `MusicGroup` model. This model introduces a C# `enum` — decide how to store it in SQL and explain your choice.

**Types to map:**
- `MusicGroupId` — `Guid`
- `Name` — `string`
- `EstablishedYear` — `int`
- `Genre` — `MusicGenre` (enum: `Rock`, `Blues`, `Jazz`, `Metal`)

**Hints:**
- SQL Server has no native enum type.
- Storing the enum name as `nvarchar` keeps the data readable without needing a lookup table.
- A size of `nvarchar(50)` is more than enough for any of the genre names.

**Suggested solution:** [01c-create-MusicGroup.sql](../01-exercise-answers/01c-create-MusicGroup.sql)

---

## Exercise 5 – Create the `Album` Table

**Task:** Write a `CREATE TABLE` statement for the `Album` model. This model introduces `long` — a C# type not seen in the `friends` schema. Map it to the correct T-SQL type.

**Types to map:**
- `AlbumId` — `Guid`
- `Name` — `string`
- `ReleaseYear` — `int`
- `CopiesSold` — `long`

**Hints:**
- `long` in C# is a 64-bit integer. `int` only holds up to ~2.1 billion — not enough for global album sales figures.
- The T-SQL equivalent of C# `long` is `bigint`.

**Suggested solution:** [01d-create-Album.sql](../01-exercise-answers/01d-create-Album.sql)

---

## Summary: New Type Mappings Introduced in These Exercises

Compared to the `friends` schema in Lesson 01, two new mappings appear:

| C# Type | T-SQL Type | Where used |
|---|---|---| 
| `long` | `bigint` | `Album.CopiesSold` — sales figures can exceed the `int` limit |
| `enum` (MusicGenre) | `nvarchar(50)` | `MusicGroup.Genre` — stored as the member name string |
