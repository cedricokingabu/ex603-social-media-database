-- Part A : Rows that do not appear
-- Using likes.removal_reason , which is nullable. Table contains 200 records
SELECT COUNT(*) AS not_identified_as_spam
FROM likes
WHERE removal_reason <> 'Spam detected';

-- result is 22 rows. Rows where removal_reason is NULL do not pass this condition: the comparison evaluates to UNKNOWN
-- and WHERE keeps only rows where the condition is TRUE.

SELECT COUNT(*) AS rows_with_null_reason
FROM likes
WHERE removal_reason IS NULL;

-- Result: 166 rows. The two counts are 22 + 166 = 188, not 200. The other 12 rows have a non-NULL reason of Spam detected; 
-- the inequality excludes those intentionally.
   
SELECT COUNT(*) AS not_identified_as_spam
FROM likes
WHERE removal_reason <> 'Spam detected'
   OR removal_reason IS NULL;
   
-- we mixed the two condition and the result is not 200 rows but 188 rows.


-- Part B : The Alias did not exist yet

SELECT
    like_id,
    dwell_ms / 1000.0 AS dwell_seconds
FROM likes
WHERE dwell_seconds > 30;

-- I get the error [42703] ERROR: column "dwell_seconds" does not exist
-- Position: 77

-- Rewrite 1 - repeat the expression in the where:
SELECT
    like_id,
    dwell_ms / 1000.0 AS dwell_seconds
FROM likes
WHERE dwell_ms / 1000.0 > 30;

-- Rewrite 2 - make the alias a column in a CTE first:
WITH reaction_durations AS (
    SELECT
        like_id,
        dwell_ms / 1000.0 AS dwell_seconds
    FROM likes
)
SELECT
    like_id,
    dwell_seconds
FROM reaction_durations
WHERE dwell_seconds > 30;


