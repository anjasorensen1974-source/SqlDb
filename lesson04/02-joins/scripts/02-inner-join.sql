USE friends;
GO

--Use Inner join to get the adresses
--Note: Friends with addressId NULL is not part of the result
SELECT * 
FROM dbo.friend f 
INNER JOIN dbo.Address a
ON f.AddressId = a.AddressId;



--Use Inner join to get the pet detail
--Note: Friends with addressId NULL is now part of the result, as it is not
--part of the join
SELECT * 
FROM dbo.friend f 
INNER JOIN dbo.Pet p ON f.FriendId = p.OwnerId;

--Use Inner join to get the address and pet detail
--Note: Friends with addressId NULL is no longer not part of the result
SELECT * 
FROM dbo.friend f 
INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
INNER JOIN dbo.Pet p ON f.FriendId = p.OwnerId;


--Use Inner join to get the quotes
SELECT f.LastName, q.QuoteText FROM dbo.friend f 
INNER JOIN dbo.FriendQuote fq ON f.FriendId = fq.FriendId
INNER JOIN dbo.Quote q ON fq.QuoteId = q.QuoteId