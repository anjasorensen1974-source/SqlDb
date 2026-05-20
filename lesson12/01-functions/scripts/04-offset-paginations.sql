USE sakila;
GO

-- House kepping
DROP FUNCTION IF EXISTS dbo.fn_GetFilmPage;
GO

CREATE FUNCTION dbo.fn_GetFilmPage
(
    @PageNumber INT,   -- 1-based page number
    @PageSize   INT    -- number of rows per page
)
RETURNS TABLE
AS
RETURN
(
    SELECT  film_id,
            title
    FROM    dbo.film
    ORDER BY film_id
    OFFSET  (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY
);
GO

-- Usage examples
SELECT * FROM dbo.fn_GetFilmPage(1, 10);   -- first page,  10 rows
SELECT * FROM dbo.fn_GetFilmPage(2, 10);   -- second page, 10 rows
SELECT * FROM dbo.fn_GetFilmPage(5, 20);   -- fifth page,  20 rows


-- House kepping
DROP FUNCTION IF EXISTS dbo.fn_GetFilmPage;
GO