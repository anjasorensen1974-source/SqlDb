USE friends;
GO

DECLARE @Harry    uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Harry'    AND LastName = 'Took');
DECLARE @Severus  uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Severus'  AND LastName = 'Gamgee');
DECLARE @Sam      uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Sam'      AND LastName = 'Baggins');
DECLARE @Lord     uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Lord'     AND LastName = 'Dumbledore');
DECLARE @Albus    uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Albus'    AND LastName = 'Potter');
DECLARE @Draco    uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Draco'    AND LastName = 'Snape');
DECLARE @Luna     uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Luna'     AND LastName = 'Weasley');
DECLARE @Neville  uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Neville'  AND LastName = 'Longbottom');
DECLARE @Ginny    uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Ginny'    AND LastName = 'Lovegood');
DECLARE @Ron      uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Ron'      AND LastName = 'Skywalker');
DECLARE @Padma    uniqueidentifier = (SELECT FriendId FROM Friend WHERE FirstName = 'Padma'    AND LastName = 'Patil');

INSERT INTO Pet
    (AnimalKind, Name, AnimalMood, OwnerId)
VALUES
    ('Cat',    'Charlie', 'Happy',   @Harry),
    ('Fish',   'Wanda',   'Lazy',    @Severus),
    ('Dog',    'Simba',   'Hungry',  @Lord),
    ('Bird',   'Max',     'Buzy',    @Lord),
    ('Cat',    'Cooper',  'Sleepy',  @Sam),
    ('Dog',    'Milo',    'Happy',   @Albus),
    ('Fish',   'Teddy',   'Sulky',   @Draco),
    ('Bird',   'Leo',     'Hungry',  @Draco),
    ('Rabbit', 'Coco',    'Happy',   @Luna),
    ('Dog',    'Biscuit', 'Sleepy',  @Luna),
    ('Cat',    'Whisker', 'Sulky',   @Neville),
    ('Fish',   'Bubble',  'Lazy',    @Ginny),
    ('Bird',   'Sunny',   'Buzy',    @Ron),
    ('Rabbit', 'Pebble',  'Happy',   @Ron),
    ('Dog',    'Rufus',   'Hungry',  @Padma),
    ('Cat',    'Mittens', 'Sleepy',  @Padma),
    ('Fish',   'Splash',  'Happy',   @Neville),
    ('Bird',   'Pepper',  'Sulky',   @Padma);
GO


INSERT INTO dbo.Pet
    (AnimalKind, Name, AnimalMood, OwnerId)
VALUES
    ('Cat',    'Charlie', 'Happy',  NULL),
    ('Fish',   'Wanda',   'Lazy',   NULL),
    ('Dog',    'Simba',   'Hungry', NULL),
    ('Bird',   'Max',     'Buzy',   NULL),
    ('Cat',    'Cooper',  'Sleepy', NULL);