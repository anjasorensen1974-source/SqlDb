# Lesson 01 – Exercises: Creating Tables with the Table Designer

These exercises recreate the three music tables — `Artist`, `MusicGroup`, and `Album` — using the **graphical Table Designer** built into the **MSSQL (SQL Server) extension** for VS Code, instead of writing `CREATE TABLE` scripts by hand.

The Table Designer lets you define columns, data types, nullability, default values, primary keys, and check constraints through a form-based UI. The extension then generates and applies the T-SQL for you.

---

## Prerequisites

- The **MSSQL** extension is installed in VS Code (`ms-mssql.mssql`).
- You have an active connection to your SQL Server instance in the **SQL Server** panel (the cylinder icon in the Activity Bar).
- The `music` database already exists. If not, run `01-create-database.sql` first.

---

## How to Open the Table Designer

1. In the **SQL Server** panel, expand your connection → **Databases** → **music** → **Tables**.
2. Right-click **Tables** and choose **New Table**.
3. The Table Designer opens as a tab. Work through the columns panel on the left and the properties panel on the right.
4. When finished, click **Publish** (or **Update Database**) to apply the changes.

To edit an existing table, right-click the table name and choose **Design**.

---

## Exercise 1 – Create the `Artist` Table

USE tempdb;
GO

DROP DATABASE music;
GO

```csharp
// Artist.cs
public Guid ArtistId { get; set; }
public string FirstName { get; set; }
public string LastName { get; set; }
public DateTime? BirthDay { get; set; }
```

**Column specification:**

| Column name | Data type | Length | Allow nulls | Default value | Notes |
|---|---|---|---|---|---|
| `ArtistId` | `uniqueidentifier` | — | No | `newid()` | Primary key |
| `FirstName` | `nvarchar` | 100 | Yes | — | |
| `LastName` | `nvarchar` | 100 | Yes | — | |
| `BirthDay` | `date` | — | Yes | — | `DateTime?` → nullable `date` |

**Steps:**
1. Open the Table Designer for a new table in `music`.
2. Set the **Table name** to `Artist`.
3. Add each column using the **+ Add Column** button. Set the name, type, length, and nullability for each row.
4. For `ArtistId`, enter `newid()` in the **Default value** field.
5. Select the `ArtistId` row and click the **Primary Key** icon (or check the **Primary Key** checkbox in the column properties) to mark it as the PK.
6. Click **Publish** to create the table.

**Expected outcome:** The `Artist` table appears under **music → Tables** in the SQL Server panel.

---

## Exercise 2 – Create the `MusicGroup` Table

**Task:** Use the Table Designer to create the `MusicGroup` table. This table includes a `Genre` column that stores the name of a C# enum value.

```csharp
// MusicGroup.cs
public enum MusicGenre { Rock, Blues, Jazz, Metal }

public Guid MusicGroupId { get; set; }
public string Name { get; set; }
public int EstablishedYear { get; set; }
public MusicGenre Genre { get; set; }
```

**Column specification:**

| Column name | Data type | Length | Allow nulls | Default value | Notes |
|---|---|---|---|---|---|
| `MusicGroupId` | `uniqueidentifier` | — | No | `newid()` | Primary key |
| `Name` | `nvarchar` | 100 | Yes | — | |
| `EstablishedYear` | `int` | — | Yes | — | |
| `Genre` | `nvarchar` | 50 | Yes | — | Stores enum name as string |

**Steps:**
1. Open the Table Designer for a new table in `music`.
2. Set the **Table name** to `MusicGroup`.
3. Add the four columns as specified above.
4. Mark `MusicGroupId` as the primary key with default `newid()`.
5. Click **Publish**.

> **Note on the enum:** SQL Server has no native enum type. Storing the genre as `nvarchar(50)` keeps the value human-readable. A check constraint to enforce the allowed values is added in a separate exercise (`03-check-constraints.md`).

**Expected outcome:** The `MusicGroup` table appears in the SQL Server panel.

---

## Exercise 3 – Create the `Album` Table

**Task:** Use the Table Designer to create the `Album` table. This table introduces `bigint`, the SQL equivalent of C# `long`.

```csharp
// Album.cs
public Guid AlbumId { get; set; }
public string Name { get; set; }
public int ReleaseYear { get; set; }
public long CopiesSold { get; set; }
```

**Column specification:**

| Column name | Data type | Length | Allow nulls | Default value | Notes |
|---|---|---|---|---|---|
| `AlbumId` | `uniqueidentifier` | — | No | `newid()` | Primary key |
| `Name` | `nvarchar` | 100 | Yes | — | |
| `ReleaseYear` | `int` | — | Yes | — | |
| `CopiesSold` | `bigint` | — | Yes | — | C# `long` = 64-bit integer |

**Steps:**
1. Open the Table Designer for a new table in `music`.
2. Set the **Table name** to `Album`.
3. Add the four columns as specified above.
4. Mark `AlbumId` as the primary key with default `newid()`.
5. Click **Publish**.

**Expected outcome:** The `Album` table appears in the SQL Server panel.

---

## Exercise 4 – Inspect the Generated Script

**Task:** Before (or instead of) clicking **Publish**, preview the T-SQL that the Table Designer would generate, and compare it to the hand-written solutions in `01-exercise-answers/`.

**Steps:**
1. After configuring a table in the Table Designer, click **Generate Script** (or the script preview button in the toolbar) instead of Publish.
2. Read the generated `CREATE TABLE` statement.
3. Compare it with the corresponding solution file (e.g. `01b-create-Artist.sql`).

**Things to look for:**
- Does the designer add `SET ANSI_NULLS ON` and `SET QUOTED_IDENTIFIER ON`?
- How does it express the `NOT NULL DEFAULT NEWID()` clause?
- Are column names and types quoted the same way?

**Expected outcome:** You can read and understand the generated T-SQL and explain any differences from the hand-written scripts.

---

## Exercise 5 – Add the `Album → MusicGroup` Foreign Key

**Task:** Use the Table Designer to add a foreign key column to `Album` that links each album to the `MusicGroup` it belongs to (many albums → one group).

**Steps:**
1. In the SQL Server panel, right-click **Album** and choose **Design**.
2. In the **Columns** panel, add a new column:

   | Column name | Data type | Allow nulls | Notes |
   |---|---|---|---|
   | `MusicGroupId` | `uniqueidentifier` | Yes | FK to `MusicGroup` |

3. Switch to the **Foreign Keys** tab in the Table Designer.
4. Click **+ Add Foreign Key**.
5. Configure the constraint:
   - **Name:** `FK_Album_MusicGroup`
   - **Referenced table:** `dbo.MusicGroup`
   - **Column mapping:** `MusicGroupId` → `MusicGroupId`
6. Click **Publish**.

**Expected outcome:** The `Album` table now has a `MusicGroupId` column. Inserting an `Album` row with a `MusicGroupId` that does not exist in `MusicGroup` is rejected. Inserting `NULL` succeeds.

---

## Exercise 6 – Create the `ArtistMusicGroup` Join Table

**Task:** Use the Table Designer to create the join table that models the many-to-many relationship between `Artist` and `MusicGroup`.

**Background:** A C# `List<>` navigation property on both sides signals a many-to-many relationship. SQL Server cannot express this with a single column — a separate join table with two foreign key columns is required.

**Column specification:**

| Column name | Data type | Allow nulls | Notes |
|---|---|---|---|
| `ArtistId` | `uniqueidentifier` | No | FK to `Artist`, part of composite PK |
| `MusicGroupId` | `uniqueidentifier` | No | FK to `MusicGroup`, part of composite PK |

**Steps:**
1. Open the Table Designer for a new table in `music`.
2. Set the **Table name** to `ArtistMusicGroup`.
3. Add the two columns above (both `NOT NULL`, no default).
4. Select **both** rows and mark them as the **Primary Key** to create a composite PK on `(ArtistId, MusicGroupId)`.
5. Switch to the **Foreign Keys** tab and add two constraints:
   - `FK_ArtistMusicGroup_Artist`: `ArtistId` → `dbo.Artist.ArtistId`
   - `FK_ArtistMusicGroup_MusicGroup`: `MusicGroupId` → `dbo.MusicGroup.MusicGroupId`
6. Click **Publish**.

**Expected outcome:** The `ArtistMusicGroup` table is created. The same `(ArtistId, MusicGroupId)` pair cannot be inserted twice. Referencing a non-existent artist or group is rejected.

---

## Exercise 7 – Add a Check Constraint on `MusicGroup.Genre`

**Task:** Use the Table Designer to restrict the `Genre` column to only the four values defined in the `MusicGenre` enum.

```csharp
public enum MusicGenre { Rock, Blues, Jazz, Metal }
```

**Steps:**
1. In the SQL Server panel, right-click **MusicGroup** and choose **Design**.
2. Switch to the **Check Constraints** tab in the Table Designer.
3. Click **+ Add Check Constraint**.
4. Configure the constraint:
   - **Name:** `CK_MusicGroup_Genre`
   - **Expression:** `[Genre] IN ('Rock', 'Blues', 'Jazz', 'Metal')`
5. Click **Publish**.

**Expected outcome:** Inserting a `MusicGroup` row with `Genre = 'Rock'` succeeds. Inserting one with `Genre = 'Pop'` is rejected with a `CHECK constraint` violation error.
