USE friends;
GO

SELECT * 
FROM dbo.friend f 
INNER JOIN dbo.Address a ON f.AddressId = a.AddressId;

--Use Outer left join to get the adresses
--Note: Friends with addressId NULL is now part of the result
SELECT * 
FROM dbo.friend f 
LEFT OUTER JOIN dbo.Address a ON f.AddressId = a.AddressId
WHERE a.AddressId IS NULL; --Filter to get only friends without an address

--Use Right Outer join to get ALL Addresses (right table), even if no Friend lives there
--Addresses not linked to any friend get NULL in friend columns
SELECT *
FROM dbo.friend f 
RIGHT OUTER JOIN dbo.Address a ON f.AddressId = a.AddressId;

--Use Full Outer join to get ALL Friends and ALL Addresses
--Friends without an address get NULL in address columns
--Addresses not linked to any friend get NULL in friend columns
SELECT *
FROM dbo.friend f 
FULL OUTER JOIN dbo.Address a ON f.AddressId = a.AddressId;


--Use Outer Left join to get the address and pet detail
--Friends with addressId NULL is now part of the result
--Only friends with a pet are part of the result, as it is an inner join
SELECT * 
FROM dbo.friend f 
LEFT OUTER JOIN dbo.Address a ON f.AddressId = a.AddressId
INNER JOIN dbo.Pet p ON f.FriendId = p.OwnerId;

--Quotes not linked to any friend get NULL in friend columns
SELECT * FROM dbo.friend f 
FULL OUTER JOIN dbo.FriendQuote fq ON f.FriendId = fq.FriendId
FULL OUTER JOIN dbo.Quote q ON fq.QuoteId = q.QuoteId
WHERE f.FriendId IS NULL; 

--Friends without a quote get NULL in quote columns
SELECT * FROM dbo.friend f 
FULL OUTER JOIN dbo.FriendQuote fq ON f.FriendId = fq.FriendId
FULL OUTER JOIN dbo.Quote q ON fq.QuoteId = q.QuoteId
WHERE q.QuoteId IS NULL; 