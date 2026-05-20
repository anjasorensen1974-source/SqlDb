USE friends;
GO

-- ============================================================
-- ROLLUP vs CUBE using friends database
-- Scenario: count how many quotes each friend has, grouped by Author
--
-- Friend -> Quote is a natural hierarchy:
--   each friend has quotes from various authors, so ROLLUP makes sense
-- ============================================================

-- ROLLUP: hierarchical subtotals  Friend -> Author -> grand total
-- Produces:
--   - quote count per author for each friend
--   - subtotal per friend across all authors  (Author = NULL)
--   - grand total                             (FriendId = NULL, Author = NULL)
SELECT
    f.FirstName,
    q.Author,
    COUNT(*) AS NrQuotes
FROM FriendQuote fq
    INNER JOIN Friend f  ON fq.FriendId = f.FriendId
    INNER JOIN Quote  q  ON fq.QuoteId  = q.QuoteId
GROUP BY f.FirstName, q.Author WITH ROLLUP
ORDER BY f.FirstName, q.Author;
GO

-- CUBE: ALL combinations of Friend and Author subtotals
-- Produces everything ROLLUP does PLUS:
--   - subtotal per author across all friends  (FirstName = NULL)
--     shows how many times each author's quotes are shared overall
SELECT
    f.FirstName,
    q.Author,
    COUNT(*) AS NrQuotes
FROM FriendQuote fq
    INNER JOIN Friend f  ON fq.FriendId = f.FriendId
    INNER JOIN Quote  q  ON fq.QuoteId  = q.QuoteId
GROUP BY CUBE(f.FirstName, q.Author)
ORDER BY f.FirstName, q.Author;
GO

-- Use GROUPING() to label NULL subtotal rows clearly
SELECT
    COALESCE(f.FirstName, 'All friends') AS Friend,
    COALESCE(q.Author, 'All authors') AS Author,
    COUNT(*) AS NrQuotes
FROM FriendQuote fq
    INNER JOIN Friend f  ON fq.FriendId = f.FriendId
    INNER JOIN Quote  q  ON fq.QuoteId  = q.QuoteId
GROUP BY CUBE(f.FirstName, q.Author)
ORDER BY f.FirstName, q.Author;
GO
