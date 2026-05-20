USE friends;
GO

--Add a Best Friend column to the Friends table
ALTER TABLE dbo.Friend  
ADD FatherId uniqueidentifier NULL;
GO

--set a couple of Fathers
UPDATE dbo.Friend
SET FatherId = (SELECT FriendId FROM dbo.Friend WHERE FirstName = 'Neville' AND LastName = 'Longbottom')
WHERE FirstName = 'Luna' AND LastName = 'Weasley';

UPDATE dbo.Friend
SET FatherId = (SELECT FriendId FROM dbo.Friend WHERE FirstName = 'Neville' AND LastName = 'Longbottom')
WHERE FirstName = 'Harry' AND LastName = 'Took';

UPDATE dbo.Friend
SET FatherId = (SELECT FriendId FROM dbo.Friend WHERE FirstName = 'Ron' AND LastName = 'Skywalker')
WHERE FirstName = 'Padma' AND LastName = 'Patil';

--use a self join to get Father details
SELECT CONCAT_WS(' ', f.FirstName, f.LastName) AS Child,
       CONCAT_WS(' ', father.FirstName, father.LastName) AS Father
FROM dbo.friend f 
INNER JOIN dbo.friend father    
ON f.FatherId = father.FriendId;

--outer join to see all children without a father
SELECT *
FROM dbo.friend f 
LEFT JOIN dbo.friend father    
ON f.FatherId = father.FriendId
WHERE father.FriendId IS NULL;

SELECT CONCAT_WS(' ', f.FirstName, f.LastName) AS Child,
       CONCAT_WS(' ', father.FirstName, father.LastName) AS Father
FROM dbo.friend f 
LEFT JOIN dbo.friend father    
ON f.FatherId = father.FriendId
WHERE father.FriendId IS NULL;


--remove the Father column
ALTER TABLE dbo.Friend 
DROP COLUMN FatherId;
