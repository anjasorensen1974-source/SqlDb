USE sakila;
GO

-- Change these two variables to navigate between pages.
DECLARE @PageNumber INT = 1;   -- Which page to retrieve (1-based)
DECLARE @PageSize   INT = 10;  -- Number of rows per page

WITH FilmsPaged AS (
    SELECT
        film_id,
        title,
        ROW_NUMBER() OVER (ORDER BY title ASC) AS rn  -- window fn: number every row in title order
    FROM film
)
SELECT
    rn          AS row_num,
    film_id,
    title
FROM FilmsPaged
WHERE rn BETWEEN (@PageNumber - 1) * @PageSize + 1
              AND  @PageNumber      * @PageSize
ORDER BY rn;

GO


-- Note CTE with ORDER BY is not allowed in a TVF so it cannot be wrapped in a function, only in a stored procedure. 
