-- create database
create database social_buzz;

SELECT * FROM social_buzz.content;
SELECT DISTINCT(Category) FROM social_buzz.content;
select count(*) from social_buzz.content;

-- CLEANING OF CONTENT DATASET
-- 1. DELETE BLANK ROWS 
SET SQL_SAFE_UPDATES = 0;
DELETE FROM social_buzz.content
WHERE `Content ID` IS NULL 
   OR `User ID` IS NULL
   OR `Type` IS NULL
   OR `Category` IS NULL
   OR `URL` IS NULL
   OR `URL` = '';

-- 2. DELETE MyUnknownColumn
SHOW COLUMNS FROM social_buzz.content;
ALTER TABLE social_buzz.content
DROP COLUMN `MyUnknownColumn`,
DROP COLUMN `URL`,
DROP COLUMN `User ID` ;

-- 3. REMNAMING OF COLUMN
ALTER TABLE social_buzz.content
RENAME COLUMN `Type` TO `Category_Type`; 

-- 4. ADD PRIMERY KEY Content ID
ALTER TABLE social_buzz.content
MODIFY COLUMN `Content ID` VARCHAR(255);
ALTER TABLE social_buzz.content
ADD PRIMARY KEY (`Content ID`); 

-- CLEANING OF reactions DATASET
SELECT * FROM social_buzz.reactions;

select count(*) from social_buzz.reactions;

-- 1. DELETING BLANK ROWS
DELETE FROM social_buzz.reactions
WHERE `Content ID` = ''
   OR `User ID` = ''
   OR `Type` = ''
   OR `Datetime` = ''
   OR `User ID` = '';
   
-- 2. DELETE MyUnknownColumn
SHOW COLUMNS FROM social_buzz.reactions;
ALTER TABLE social_buzz.reactions
DROP COLUMN `MyUnknownColumn`,
DROP COLUMN `User ID`;

-- 3. ALTER DATATYPE
ALTER TABLE social_buzz.reactions
MODIFY COLUMN `Datetime` TIMESTAMP;


SELECT `User ID`, COUNT(*) AS _COUNT_
FROM social_buzz.reactions
GROUP BY `User ID`
HAVING _COUNT_ >= 2;



-- CLEANING OF reaction_types DATASET
SELECT * FROM social_buzz.reaction_types;

select count(*) from social_buzz.reaction_types;

-- 4. ADD PRIMERY KEY Type
ALTER TABLE social_buzz.reaction_types
MODIFY COLUMN `Type` VARCHAR(255);
ALTER TABLE social_buzz.reaction_types
ADD PRIMARY KEY (`Type`); 

-- 1. DELETING BLANK ROWS
SHOW COLUMNS FROM social_buzz.reaction_types;
DELETE FROM social_buzz.reaction_types
WHERE `Type` IS NULL
   OR `Sentiment` IS NULL
   OR `Score` = '';
   
-- 2. DELETE MyUnknownColumn
SHOW COLUMNS FROM social_buzz.reaction_types;
ALTER TABLE social_buzz.reaction_types
DROP COLUMN `MyUnknownColumn`;

-- CREATE A CLEAN FINAL DATASET 
CREATE TABLE social_buzz.final_reactions_data AS
SELECT 
    R.`Content ID`, 
    R.Type AS reaction_type,
    R.Datetime AS reaction_datetime,
    C.Category_Type AS content_category_type,
    C.Category AS content_category,
    RT.Type AS reaction_type_name,
    RT.Sentiment AS reaction_sentiment,
    RT.Score AS reaction_score
FROM social_buzz.reactions AS R
JOIN social_buzz.content AS C
    ON R.`Content ID` = C.`Content ID` 
JOIN social_buzz.reaction_types AS RT
    ON R.Type = RT.Type;
    
SELECT * FROM social_buzz.final_reactions_data;
SHOW COLUMNS FROM social_buzz.final_reactions_data;

-- QUESTION = An analysis of their content categories that highlights the top 5 categories with the largest aggregate popularity 
SELECT 
    content_category, 
    SUM(reaction_score) AS total_popularity
FROM 
    social_buzz.final_reactions_data
GROUP BY 
    content_category
ORDER BY 
    total_popularity DESC
LIMIT 5; 
