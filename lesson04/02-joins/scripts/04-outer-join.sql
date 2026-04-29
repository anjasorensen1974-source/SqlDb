USE friends;
GO

SELECT * 
FROM dbo.friend f 
INNER JOIN dbo.Address a ON f.AddressId = a.AddressId;

--Use Outer left join to get the adresses
--Note: Friends with addressId NULL is now part of the result
SELECT * 
FROM dbo.friend f 
LEFT OUTER JOIN dbo.Address a ON f.AddressId = a.AddressId;

--Use Right Outer join to get ALL Addresses (right table), even if no Friend lives there
--Addresses not linked to any friend get NULL in friend columns
SELECT f.FirstName, f.LastName, a.StreetAddress, a.City
FROM dbo.friend f 
RIGHT OUTER JOIN dbo.Address a ON f.AddressId = a.AddressId
WHERE f.FriendId IS NULL; --This will give you only the addresses not linked to any friend

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