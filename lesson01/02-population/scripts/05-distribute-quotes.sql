USE friends;
GO

-- Friends
DECLARE @Harry    uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Harry'    AND LastName = 'Took');
DECLARE @Severus  uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Severus'  AND LastName = 'Gamgee');
DECLARE @Sam      uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Sam'      AND LastName = 'Baggins');
DECLARE @Saruman  uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Saruman'  AND LastName = 'Malfoy');
DECLARE @Lord     uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Lord'     AND LastName = 'Dumbledore');
DECLARE @Hermione uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Hermione' AND LastName = 'Granger');
DECLARE @Albus    uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Albus'    AND LastName = 'Potter');
DECLARE @Draco    uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Draco'    AND LastName = 'Snape');

-- Quotes
DECLARE @Q1  uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Woody Allen');
DECLARE @Q2  uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Billy Connolly');
DECLARE @Q3  uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Lily Tomlin');
DECLARE @Q4  uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Terry Pratchett');
DECLARE @Q5  uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Winnie the Pooh');
DECLARE @Q6  uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Jim Carrey');
DECLARE @Q7  uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Steve Martin');
DECLARE @Q8  uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Anonymous');
DECLARE @Q9  uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Will Rogers');
DECLARE @Q10 uniqueidentifier = (SELECT TOP 1 QuoteId FROM Quote WHERE Author = 'Billie Burke');

--distribute quotes among friends
INSERT INTO FriendQuote
    (FriendId, QuoteId)
VALUES
    -- Harry has three quotes
    (@Harry,    @Q1),
    (@Harry,    @Q3),
    (@Harry,    @Q7),
    -- Severus has two quotes
    (@Severus,  @Q2),
    (@Severus,  @Q8),
    -- Sam has two quotes
    (@Sam,      @Q4),
    (@Sam,      @Q9),
    -- Saruman has one quote
    (@Saruman,  @Q5),
    -- Lord has two quotes
    (@Lord,     @Q6),
    (@Lord,     @Q10),
    -- Hermione has one quote
    (@Hermione, @Q3),
    -- Albus has two quotes
    (@Albus,    @Q1),
    (@Albus,    @Q2),
    -- Draco has one quote
    (@Draco,    @Q5);
GO