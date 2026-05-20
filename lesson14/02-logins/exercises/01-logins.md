# Lesson 14 – Exercises: Logins, Server Roles, and Database Users

These exercises practise the three-tier SQL Server security model:

| Tier | Scope | Key objects |
|---|---|---|
| **Login** | Server | `CREATE LOGIN`, `sys.sql_logins` |
| **Server role** | Server | `CREATE SERVER ROLE`, `GRANT … TO role`, `ALTER SERVER ROLE ADD/DROP MEMBER` |
| **Database user** | Database | `CREATE USER FROM LOGIN`, `GRANT CONNECT`, `GRANT SELECT / INSERT / …` |

All scripts must be run as an administrator (`sa` or a `sysadmin` member).

---

## Exercise 1 – Create a SQL Server Login

**Concepts:** `CREATE LOGIN`, password options, `sys.sql_logins`, safe cleanup with `IF SUSER_ID(...) IS NOT NULL`.

**Task:**

1. Write safe **house-cleaning** code that drops the login `Bilbo` only if it already exists, using `IF SUSER_ID(N'Bilbo') IS NOT NULL DROP LOGIN Bilbo`.

2. Create the login with the statement below (fill in the blanks):

   ```sql
   CREATE LOGIN Bilbo WITH PASSWORD = N'pa$$W0rd!',
       DEFAULT_DATABASE = tempdb,
       DEFAULT_LANGUAGE = us_english,
       CHECK_EXPIRATION = OFF,
       CHECK_POLICY     = OFF;
   ```

3. Verify the login was created by querying `sys.sql_logins` and filtering on `name = 'Bilbo'`. Return the `name`, `type_desc`, `default_database_name`, and `is_policy_checked` columns.

4. Clean up by dropping the login.

**Hint:** All login management runs in the `master` database — start with `USE master; GO`. The `SUSER_ID()` function returns `NULL` when the login does not exist, making it safe to use in an `IF` guard.

**Expected outcome:** The login appears in `sys.sql_logins` after step 2, and the query in step 3 returns exactly one row for `Bilbo`. After cleanup the login is gone.

**Answer:** [01-logins.sql](../exercise-answers/01-logins.sql)

---

## Exercise 2 – Create a Server Role and Grant Server-Level Permissions

**Concepts:** `CREATE SERVER ROLE`, `GRANT CONNECT ANY DATABASE`, `GRANT VIEW ANY DATABASE`, `GRANT SELECT ALL USER SECURABLES`, `ALTER SERVER ROLE ADD MEMBER`, `sys.server_role_members`.

**Task:**

1. Write safe house-cleaning code that:
   - Removes login `Pippin` from role `ReadAnyDB` if that membership exists (check `sys.server_role_members` joined with `sys.server_principals`).
   - Drops role `ReadAnyDB` if it exists (check `sys.server_principals WHERE name = N'ReadAnyDB' AND type = 'R'`).
   - Drops login `Pippin` if it exists.

2. Create login `Pippin` (`PASSWORD = N'pa$$W0rd!'`, `DEFAULT_DATABASE = tempdb`, `CHECK_EXPIRATION = OFF`, `CHECK_POLICY = OFF`).

3. Create server role `ReadAnyDB`.

4. Grant all three of the following permissions to `ReadAnyDB`:
   - `CONNECT ANY DATABASE`
   - `VIEW ANY DATABASE`
   - `SELECT ALL USER SECURABLES`

5. Add `Pippin` as a member of `ReadAnyDB`.

6. Verify the membership by querying `sys.server_role_members` joined with `sys.server_principals` (once for the member, once for the role), returning `member_name` and `role_name`.

7. Clean up: remove `Pippin` from the role, drop the role, drop the login.

**Hint:** Use `ALTER SERVER ROLE ReadAnyDB ADD MEMBER Pippin` to add the member. Each `GRANT` statement targets the role, not the login directly — the login inherits the permissions through role membership.

**Expected outcome:** The verification query in step 6 returns one row showing `Pippin` as a member of `ReadAnyDB`. After cleanup all three objects are removed.

**Answer:** [01-logins.sql](../exercise-answers/01-logins.sql)

---

## Exercise 3 – Create a Database User and Grant Database Permissions

**Concepts:** `CREATE USER … FROM LOGIN`, `GRANT CONNECT`, object-level `GRANT SELECT`, `sys.database_principals`, the difference between a server-level login and a database-level user.

**Task:**

1. Write safe house-cleaning code (in `USE master`) that drops user `MerryUser` from the `music` database if it exists (`DROP USER IF EXISTS`) and drops login `Merry` if it exists (`IF SUSER_ID(N'Merry') IS NOT NULL`).

2. Create login `Merry` (`PASSWORD = N'pa$$W0rd!'`, `DEFAULT_DATABASE = tempdb`, `CHECK_EXPIRATION = OFF`, `CHECK_POLICY = OFF`).

3. Switch to the `music` database. Create a database user `MerryUser` mapped to the login `Merry`:

   ```sql
   CREATE USER MerryUser FROM LOGIN Merry;
   ```

4. Grant `MerryUser` permission to connect to the database:

   ```sql
   GRANT CONNECT TO MerryUser;
   ```

5. Grant `MerryUser` read access to two specific tables:

   ```sql
   GRANT SELECT ON dbo.Artist TO MerryUser;
   GRANT SELECT ON dbo.Album  TO MerryUser;
   ```

6. Verify the user was created by querying `sys.database_principals WHERE type_desc = 'SQL_USER'`, returning `name`, `type_desc`, and `default_schema_name`.

7. Clean up: drop `MerryUser` from the `music` database, then drop login `Merry`.

**Hint:** The `CREATE USER` and `GRANT` statements must run **inside the target database** (`USE music`). The login exists at the server level; the user exists only within the one database it was created in. `DROP USER` also runs inside that database.

**Expected outcome:** The query in step 6 shows `MerryUser` in `music`. `Merry` can `SELECT` from `Artist` and `Album` but has no other permissions. After cleanup both the user and the login are removed.

**Answer:** [01-logins.sql](../exercise-answers/01-logins.sql)
