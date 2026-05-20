# Lesson 14 – Exercises: Principals, Roles, Permissions, and Schema Securables

These exercises practise the concepts demonstrated in scripts 01–06:

| Script | Concept | Key objects / statements |
|---|---|---|
| 01-principals | Exploring database principals | `sys.database_principals`, `sys.database_role_members`, `SUSER_SNAME()`, `USER_NAME()` |
| 01-roles | Custom roles | `CREATE ROLE`, `ALTER ROLE ADD/DROP MEMBER`, `GRANT … TO role` |
| 02-built-in-roles | Built-in database roles | `CREATE LOGIN`, `CREATE USER FROM LOGIN`, `ALTER ROLE db_datareader ADD MEMBER` |
| 03-roles-permissions | Verifying role permissions | `IS_MEMBER()`, `HAS_PERMS_BY_NAME()`, `INFORMATION_SCHEMA.TABLES` |
| 04-schema-permissions | Schema-level permissions | `CREATE SCHEMA`, `GRANT … ON SCHEMA::`, `DENY … ON object` |
| 06-show-schema-objects | Exploring schema objects | `sys.objects`, `SCHEMA_NAME()`, grouped counts by type |

All scripts must be run as an administrator (`sa` or a `sysadmin` member) unless stated otherwise.

---

## Exercise 1 – Exploring Database Principals

**Concepts:** `sys.database_principals`, `sys.database_role_members`, `SUSER_SNAME()`, `USER_NAME()`.

**Task:**

1. Switch to the `friends` database.

2. Query `sys.database_principals` to list all **SQL users** (filter `type_desc = 'SQL_USER'`). Return all columns.

3. Query the current server-level and database-level principal names using the built-in functions:
   ```sql
   SELECT SUSER_SNAME() AS ServerPrincipalName,
          USER_NAME()    AS DatabasePrincipalName;
   ```

4. Query `sys.database_principals` to list all **database roles** (filter `type = 'R'`). Return all columns.

5. Write a query that shows every database role together with its members. Use a `RIGHT OUTER JOIN` from `sys.database_role_members` to `sys.database_principals` (roles), and a `LEFT OUTER JOIN` to `sys.database_principals` (members). Return:
   - `DatabaseRoleName` — the role name
   - `DatabaseUserName` — the member name, or `'No members'` when there are none (use `ISNULL`)

   Filter so only roles (`type = 'R'`) appear in the result, and order by role name.

**Hint:** `sys.database_role_members` has `role_principal_id` and `member_principal_id` columns that both reference `sys.database_principals.principal_id`.

**Expected outcome:** You will see the fixed built-in roles (`db_owner`, `db_datareader`, etc.) plus any custom roles. Most built-in roles will show `'No members'` in a freshly created database.

**Answer:** [01-roles-and-permissions.sql](../exercise-answers/01-roles-and-permissions.sql)

---

## Exercise 2 – Creating a Custom Role and Assigning Members

**Concepts:** `CREATE USER WITHOUT LOGIN`, `CREATE ROLE`, `GRANT … TO role`, `ALTER ROLE ADD MEMBER`, `EXECUTE AS USER`, `REVERT`.

**Task:**

1. In the `friends` database, write safe house-cleaning code that:
   - Drops members from role `readersRole` if the role exists (members: `SiriusUser`, `LupinUser`, `TonksUser`).
   - Drops the role `readersRole` if it exists.
   - Drops users `SiriusUser`, `LupinUser`, and `TonksUser` if they exist.

2. Create the three users without logins.

3. Create database role `readersRole`.

4. Grant `readersRole` the `SELECT` permission on all four tables: `dbo.Friend`, `dbo.Pet`, `dbo.Address`, and `dbo.Quote`.

5. Add all three users as members of `readersRole`.

6. Impersonate `LupinUser` and verify:
   - `SELECT TOP 5 * FROM dbo.Friend` — should succeed.
   - An `UPDATE` on `dbo.Friend` inside a `TRY/CATCH` block — should fail; display the error message.

7. End the impersonation with `REVERT`.

8. Verify role membership by querying the role/member join (same query as Exercise 1, step 5), filtered to show only `readersRole`.

9. Run the full house-cleaning block again to remove all objects created.

**Hint:** Permissions granted to a role are automatically inherited by every member. You never need to grant permissions directly to individual users if they all belong to the same role.

**Expected outcome:**
- Step 6 `SELECT` returns rows; `UPDATE` is caught with a permission-denied error.
- Step 8 returns three rows: `SiriusUser`, `LupinUser`, and `TonksUser` — all in `readersRole`.

**Answer:** [01-roles-and-permissions.sql](../exercise-answers/01-roles-and-permissions.sql)

---

## Exercise 3 – Using Built-in Database Roles

**Concepts:** `CREATE LOGIN`, `CREATE USER FROM LOGIN`, `ALTER ROLE db_datareader ADD MEMBER`, `DROP USER`, `DROP LOGIN`.

**Task:**

1. Write safe house-cleaning code in `master` that drops login `Aragorn` if it exists.

2. Switch to the `friends` database and drop user `AragornUser` if it exists.

3. Switch back to `master` and create SQL login `Aragorn` with:
   - `PASSWORD = N'pa$$W0rd!'`
   - `DEFAULT_DATABASE = friends`
   - `CHECK_EXPIRATION = OFF`, `CHECK_POLICY = OFF`

4. Switch to the `friends` database and create database user `AragornUser` mapped to login `Aragorn`.

5. Add `AragornUser` to the built-in role `db_datareader`.

6. Verify membership by querying the role/member join (from Exercise 1, step 5), filtered to `db_datareader`.

7. While still as admin, impersonate `AragornUser` and confirm:
   - `SELECT TOP 3 * FROM dbo.Friend` — should succeed (inherited from `db_datareader`).
   - An `INSERT` into `dbo.Friend` inside a `TRY/CATCH` block — should fail; display the error.

8. End the impersonation with `REVERT`.

9. Clean up: remove `AragornUser` from the database and drop login `Aragorn`.

**Hint:** `db_datareader` grants `SELECT` on every table and view in the database. It does **not** grant `INSERT`, `UPDATE`, or `DELETE`.

**Expected outcome:**
- Step 6 shows `AragornUser` as a member of `db_datareader`.
- Step 7 `SELECT` succeeds; `INSERT` is caught with a permission-denied error.

**Answer:** [01-roles-and-permissions.sql](../exercise-answers/01-roles-and-permissions.sql)

---

## Exercise 4 – Verifying Role Membership and Table Permissions

**Concepts:** `IS_MEMBER()`, `HAS_PERMS_BY_NAME()`, `INFORMATION_SCHEMA.TABLES`, impersonation.

**Task:**

1. In the `friends` database, write safe house-cleaning code to drop user `RemusUser` and role `checkRole` if they exist (remember to drop the member from the role first).

2. Create user `RemusUser` without a login.

3. Create database role `checkRole` and grant it `SELECT` and `INSERT` permissions on `dbo.Friend` and `dbo.Pet` only.

4. Add `RemusUser` as a member of `checkRole`.

5. Impersonate `RemusUser` and run the following checks:

   a. Use `IS_MEMBER('checkRole')` to confirm membership. Display a descriptive message: `'Member of checkRole'` or `'NOT member of checkRole'`.

   b. Query `INFORMATION_SCHEMA.TABLES` and use `HAS_PERMS_BY_NAME()` to build a permission matrix. For every table visible to `RemusUser`, return:
      - `tableName` (schema + '.' + table name)
      - `AllowSelect` (1 or 0)
      - `AllowInsert` (1 or 0)
      - `AllowDelete` (1 or 0)
      - `AllowUpdate` (1 or 0)

6. End the impersonation with `REVERT`.

7. Clean up by removing `RemusUser` from `checkRole`, dropping `checkRole`, and dropping `RemusUser`.

**Hint:** `HAS_PERMS_BY_NAME(object_name, 'OBJECT', 'SELECT')` returns `1` if the current user has the named permission, `0` otherwise. `INFORMATION_SCHEMA.TABLES` only lists tables the current user can see.

**Expected outcome:**
- Step 5a returns `'Member of checkRole'`.
- Step 5b shows `AllowSelect = 1` and `AllowInsert = 1` for `dbo.Friend` and `dbo.Pet`; `AllowDelete = 0` and `AllowUpdate = 0` for all rows.

**Answer:** [01-roles-and-permissions.sql](../exercise-answers/01-roles-and-permissions.sql)

---

## Exercise 5 – Schema-Level Permissions

**Concepts:** `CREATE SCHEMA`, `CREATE VIEW` inside a non-`dbo` schema, `DENY … ON object TO role`, `GRANT … ON SCHEMA:: TO role`, impersonation to validate access.

**Task:**

1. In the `friends` database, write safe house-cleaning code that:
   - Drops user `TheodenUser` if it exists.
   - Drops role `kingsRole` if it exists (remove members first).
   - Drops views `usr.vwFriend`, `usr.vwPet`, and `usr.vwAddress` if they exist.
   - Drops schema `usr` if it exists.

2. Create schema `usr` (separate `GO` batch required after `CREATE SCHEMA`).

3. In schema `usr`, create three views that expose only selected columns:
   - `usr.vwFriend` → `FirstName`, `LastName` from `dbo.Friend`
   - `usr.vwPet` → `Name`, `Kind` from `dbo.Pet`
   - `usr.vwAddress` → `Street`, `City` from `dbo.Address`

4. Create database role `kingsRole`.

5. **Deny** direct `SELECT` on the three base tables to `kingsRole`:
   ```sql
   DENY SELECT ON dbo.Friend  TO kingsRole;
   DENY SELECT ON dbo.Pet     TO kingsRole;
   DENY SELECT ON dbo.Address TO kingsRole;
   ```

6. **Grant** `SELECT` and `EXECUTE` on the entire `usr` schema to `kingsRole`:
   ```sql
   GRANT SELECT, EXECUTE ON SCHEMA::usr TO kingsRole;
   ```

7. Create user `TheodenUser` without a login and add them to `kingsRole`.

8. Impersonate `TheodenUser` and verify:
   - `SELECT * FROM usr.vwFriend` — should succeed.
   - `SELECT * FROM usr.vwPet` — should succeed.
   - `SELECT TOP 1 * FROM dbo.Friend` inside a `TRY/CATCH` — should fail (DENY overrides any inherited SELECT); display the error.

9. End the impersonation with `REVERT`.

10. Clean up: remove `TheodenUser` from `kingsRole`, drop `kingsRole`, drop `TheodenUser`, drop the three views, and drop schema `usr`.

**Hint:** `DENY` takes precedence over `GRANT`, even when the `GRANT` comes via a role. A schema-level `GRANT` applies to all current and future objects in that schema — tables, views, and stored procedures alike.

**Expected outcome:**
- Steps 8a and 8b return rows from the views with only the allowed columns.
- Step 8c is caught with a permission-denied error because of the explicit `DENY` on the base table.

**Answer:** [01-roles-and-permissions.sql](../exercise-answers/01-roles-and-permissions.sql)

---

## Exercise 6 – Exploring Schema Objects

**Concepts:** `sys.objects`, `SCHEMA_NAME()`, `GROUP BY` with aggregation, filtering by object type.

**Task:**

1. Switch to the `friends` database.

2. Write a query against `sys.objects` that returns the **count of objects per schema per type**, limited to the following `type_desc` values:
   - `'SQL_STORED_PROCEDURE'`
   - `'CLR_STORED_PROCEDURE'`
   - `'SQL_SCALAR_FUNCTION'`
   - `'CLR_SCALAR_FUNCTION'`
   - `'CLR_TABLE_VALUED_FUNCTION'`
   - `'SYNONYM'`
   - `'SQL_INLINE_TABLE_VALUED_FUNCTION'`
   - `'SQL_TABLE_VALUED_FUNCTION'`
   - `'USER_TABLE'`
   - `'VIEW'`

   Return:
   - `schema_name` — use `SCHEMA_NAME(schema_id)`
   - `type_desc`
   - `object_count` — `COUNT(*)`

   Order by `schema_name`.

3. Re-run the query after completing Exercise 5 (while the `usr` schema and its views still exist) and note how the result changes — the `usr` schema should appear with `type_desc = 'VIEW'` and a count of `3`.

4. **Bonus:** Modify the query to also include `dbo`-schema objects and confirm the four base tables appear as `USER_TABLE`.

**Hint:** `sys.objects` contains all database objects. `SCHEMA_NAME(schema_id)` converts the integer `schema_id` to a human-readable schema name.

**Expected outcome:**
- The `dbo` schema shows `USER_TABLE` with a count of `4` (Friend, Pet, Address, Quote).
- After Exercise 5, `usr` schema shows `VIEW` with a count of `3`.

**Answer:** [01-roles-and-permissions.sql](../exercise-answers/01-roles-and-permissions.sql)
