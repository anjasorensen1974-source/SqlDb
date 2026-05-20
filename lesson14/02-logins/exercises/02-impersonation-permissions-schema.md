# Lesson 14 – Exercises: Impersonation, Database Permissions, and Schema-Scoped Securables

These exercises practise the three concepts demonstrated in scripts 04, 05, and 06:

| Concept | Key statements |
|---|---|
| **Impersonation** | `EXECUTE AS USER`, `REVERT`, `USER`, `SYSTEM_USER`, `ORIGINAL_LOGIN()` |
| **Database permissions** | `GRANT … ON … TO`, `sys.database_permissions` |
| **Schema-scoped securables** | Granting on specific tables/views, restricting access via views |

All scripts must be run as an administrator (`sa` or a `sysadmin` member).

---

## Exercise 1 – Impersonation with `EXECUTE AS USER`

**Concepts:** `CREATE USER WITHOUT LOGIN`, `EXECUTE AS USER`, `REVERT`, `USER`, `SYSTEM_USER`, `ORIGINAL_LOGIN()`.

**Task:**

1. Write safe house-cleaning code that drops user `SamUser` from `master` if it already exists:
   ```sql
   DROP USER IF EXISTS SamUser;
   ```

2. Create a user with no login in the `master` database:
   ```sql
   CREATE USER SamUser WITHOUT LOGIN;
   ```

3. Before impersonating, query your current identity using:
   ```sql
   SELECT USER              AS UserName,
          SYSTEM_USER       AS SystemUserName,
          ORIGINAL_LOGIN()  AS OriginalLoginName;
   ```

4. Start an impersonation session as `SamUser`:
   ```sql
   EXECUTE AS USER = 'SamUser';
   ```

5. Inside the impersonation session, run the same identity query again. Note how `USER` and `SYSTEM_USER` differ from `ORIGINAL_LOGIN()`.

6. While still impersonating, try to switch to the `friends` database inside a `BEGIN TRY / BEGIN CATCH` block and capture the error message. Explain why it fails.

7. End the impersonation session with `REVERT` and run the identity query once more to confirm you are back to your original login.

8. Clean up by dropping `SamUser`.

**Hint:** `ORIGINAL_LOGIN()` always returns the login that opened the connection, regardless of how many `EXECUTE AS` calls are nested. `USER` returns the name of the *current* database principal.

**Expected outcome:**
- Step 3 shows your admin login for all three columns.
- Step 5 shows `SamUser` for `UserName`, but your admin login is still visible in `ORIGINAL_LOGIN()`.
- Step 6 produces a permission-denied error message caught by `CATCH`.
- Step 7 shows all three columns restored to the admin values.

**Answer:** [02-impersonation-permissions-schema.sql](../exercise-answers/02-impersonation-permissions-schema.sql)

---

## Exercise 2 – Granting and Querying Database Permissions

**Concepts:** `CREATE USER WITHOUT LOGIN`, `GRANT SELECT / INSERT ON … TO`, `EXECUTE AS USER`, `REVERT`, `sys.database_permissions`.

**Task:**

1. In the `friends` database, write safe house-cleaning code to drop user `MeriadocUser` if it exists.

2. Create database user `MeriadocUser` without a login.

3. Grant `MeriadocUser` the `SELECT` permission on `dbo.Friend` and the `SELECT` permission on `dbo.Address`.  
   **Do not** grant any other permissions.

4. Start an impersonation session as `MeriadocUser` and verify the following:
   - `SELECT TOP 5 * FROM dbo.Friend` — should succeed.
   - `SELECT TOP 5 * FROM dbo.Address` — should succeed.
   - An `INSERT` into `dbo.Friend` inside a `TRY/CATCH` block — should fail; capture and display the error.
   - A `SELECT` from `dbo.Pet` inside a `TRY/CATCH` block — should fail; capture and display the error.

5. End the impersonation session with `REVERT`.

6. Query `sys.database_permissions` to list all permissions granted to `MeriadocUser`. Return the following columns:
   - `class_desc` — the type of securable
   - The schema-qualified object name (hint: use `OBJECT_SCHEMA_NAME` and `OBJECT_NAME` with `major_id`)
   - `permission_name`
   - `state_desc`
   - The grantee name (hint: use `USER_NAME(grantee_principal_id)`)

   Filter the results to show only rows for `MeriadocUser`.

7. Clean up by dropping `MeriadocUser`.

**Hint:** `sys.database_permissions` contains one row per permission grant. When `class_desc = 'OBJECT_OR_COLUMN'`, `major_id` is the `object_id` of the table or view.

**Expected outcome:**
- Steps 4a and 4b return rows from the respective tables.
- Steps 4c and 4d produce caught permission-denied errors.
- Step 6 returns exactly two rows — one `SELECT` on `dbo.Friend` and one `SELECT` on `dbo.Address` — both with `state_desc = 'GRANT'`.

**Answer:** [02-impersonation-permissions-schema.sql](../exercise-answers/02-impersonation-permissions-schema.sql)

---

## Exercise 3 – Schema-Scoped Securables via a View

**Concepts:** `CREATE VIEW`, granting on a view (not the base tables), impersonating to validate least-privilege access.

**Task:**

1. In the `friends` database, write safe house-cleaning code that:
   - Drops user `GollumUser` if it exists.
   - Drops view `dbo.vw_FriendStats` if it exists.

2. Create the view `dbo.vw_FriendStats` that returns four summary columns in a single row:
   - `NrOfFriends` — count of rows in `dbo.Friend`
   - `NrOfPets` — count of rows in `dbo.Pet`
   - `NrOfAddresses` — count of rows in `dbo.Address`
   - `NrOfQuotes` — count of rows in `dbo.Quote`

3. Create database user `GollumUser` without a login.

4. Grant `GollumUser` the `SELECT` permission **only on the view** `dbo.vw_FriendStats`.  
   **Do not** grant any permission on the underlying tables.

5. Start an impersonation session as `GollumUser` and verify:
   - `SELECT * FROM dbo.vw_FriendStats` — should succeed and return the four counts.
   - A `SELECT TOP 1 * FROM dbo.Friend` inside a `TRY/CATCH` block — should fail; capture the error.
   - A `SELECT TOP 1 * FROM dbo.Pet` inside a `TRY/CATCH` block — should fail; capture the error.

6. End the impersonation session with `REVERT`.

7. Clean up by dropping `GollumUser` and the view `dbo.vw_FriendStats`.

**Hint:** When a view is owned by the same schema owner as the underlying tables (ownership chaining), a user who has `SELECT` on the view can read through it even without direct table permissions. This is a key pattern for exposing summary data without exposing raw tables.

**Expected outcome:**
- Step 5a returns a single row with four integer counts.
- Steps 5b and 5c produce caught permission-denied errors proving that `GollumUser` cannot access the base tables directly.

**Answer:** [02-impersonation-permissions-schema.sql](../exercise-answers/02-impersonation-permissions-schema.sql)
