# Lesson 01 – Exercises: Primary Keys and Relationships with SQL Scripts in the Music Database

These exercises extend the `music` database created in the previous exercises by adding primary key constraints and foreign key relationships. They mirror what `02-primary-keys.sql` and `03-relationships.sql` do for the `friends` database.

Run your table-creation scripts first (`01b` – `01d`) before attempting these exercises.

---

## Reference: C# Navigation Properties

The relationship properties on each model tell you what kind of relationship exists between the tables:

```csharp
// Artist.cs
public List<MusicGroup> MusicGroups { get; set; }   // many-to-many with MusicGroup

// MusicGroup.cs
public List<Album> Albums { get; set; }              // one-to-many: MusicGroup has many Albums
public List<Artist> Artists { get; set; }            // many-to-many with Artist

// Album.cs
public MusicGroup MusicGroup { get; set; }           // many-to-one: Album belongs to one MusicGroup
```

---

## Exercise 1 – Add Primary Keys

**Task:** Write a single script that adds a named primary key constraint to each of the three tables: `Artist`, `MusicGroup`, and `Album`.

**Hints:**
- Use `ALTER TABLE … ADD CONSTRAINT … PRIMARY KEY` — the same pattern as `02-primary-keys.sql` in Lesson 01 theory.
- The naming convention is `PK_<TableName>`.
- Each table already has a `uniqueidentifier` column that should become the primary key.

| Table | Primary key column |
|---|---|
| `Artist` | `ArtistId` |
| `MusicGroup` | `MusicGroupId` |
| `Album` | `AlbumId` |

**Expected outcome:** Running the script against the `music` database succeeds without errors. Attempting to insert two rows with the same key value is rejected.


---

## Exercise 2 – Add the `Album → MusicGroup` Relationship

**Task:** Write a script that links each `Album` to the `MusicGroup` it belongs to.

**Cardinality:** Many-to-one — many albums can belong to one music group; each album belongs to at most one group.

**Steps to complete:**
1. Add a nullable `MusicGroupId` column of type `uniqueidentifier` to the `Album` table.
2. Add a foreign key constraint that references `MusicGroup.MusicGroupId`.

**Hints:**
- Make the column `NULL`-able (`NULL`). An album row may exist before a group is assigned.
- The FK constraint name convention is `FK_<ChildTable>_<ParentTable>`.
- Look at how `FK_Pet_Friend` is defined in `03-relationships.sql` — the pattern is identical.

```
Album (many) ──────────────> MusicGroup (one)
  MusicGroupId  ──FK──>  MusicGroupId (PK)
```

**Expected outcome:** Inserting an `Album` row with a `MusicGroupId` that does not exist in `MusicGroup` is rejected. Inserting `NULL` succeeds.

---

## Exercise 3 – Add the `Artist ↔ MusicGroup` Relationship

**Task:** Write a script that models the many-to-many relationship between artists and music groups.

**Cardinality:** Many-to-many — an artist can be a member of multiple groups (e.g. a side project); a group can have multiple artists.

**Hints:**
- A many-to-many relationship cannot be expressed with a single foreign key column on either side.
- You need to create a **join table** — a new table with two foreign key columns, one pointing to each side.
- Name the join table `ArtistMusicGroup`.
- Use a **composite primary key** on `(ArtistId, MusicGroupId)` to prevent the same pair from appearing twice.
- Look at how `FriendQuote` is created in `03-relationships.sql` — the pattern is the same.

**Join table structure to aim for:**

| Column | Type | Role |
|---|---|---|
| `ArtistId` | `uniqueidentifier NOT NULL` | FK → `Artist.ArtistId` |
| `MusicGroupId` | `uniqueidentifier NOT NULL` | FK → `MusicGroup.MusicGroupId` |
| *(composite PK)* | `(ArtistId, MusicGroupId)` | Prevents duplicate pairs |

```
Artist (many) <──── ArtistMusicGroup ────> MusicGroup (many)
  ArtistId (PK)      ArtistId (FK)           MusicGroupId (PK)
                     MusicGroupId (FK)
```

**Expected outcome:** The same `(ArtistId, MusicGroupId)` pair cannot be inserted twice. Each side can still be referenced independently.

---

## Summary: Relationships in the Music Database

| Relationship | Type | How modelled |
|---|---|---|
| `Album → MusicGroup` | Many-to-one | `MusicGroupId` FK column on `Album` |
| `Artist ↔ MusicGroup` | Many-to-many | `ArtistMusicGroup` join table with two FK columns |
