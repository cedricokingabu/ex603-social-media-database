-- Task 3.3 — Find users involved in spam removals
-- 1 Subquery with IN
SELECT u.user_id, u.user_name, u.country, u.is_active
FROM users AS u
WHERE u.user_id IN (
    SELECT l.user_id
    FROM likes AS l
    WHERE l.reaction_status = 'removed'
      AND l.removal_reason = 'Spam detected'
);

-- 2 Common Table Expression
WITH spam_actors AS (
    SELECT DISTINCT l.user_id
    FROM likes AS l
    WHERE l.reaction_status = 'removed'
      AND l.removal_reason = 'Spam detected'
)
SELECT u.user_id, u.user_name, u.country, u.is_active
FROM users AS u
JOIN spam_actors AS s
  ON s.user_id = u.user_id;

--3 Correlated Subquery with EXISTS
SELECT u.user_id, u.user_name, u.country, u.is_active
FROM users AS u
WHERE EXISTS (
    SELECT 1
    FROM likes AS l
    WHERE l.user_id = u.user_id
      AND l.reaction_status = 'removed'
      AND l.removal_reason = 'Spam detected'
);


-- All 3 queries return 10 rows.

WITH
q_in AS (
    SELECT u.user_id, u.user_name, u.country, u.is_active
    FROM users AS u
    WHERE u.user_id IN (
        SELECT l.user_id
        FROM likes AS l
        WHERE l.reaction_status = 'removed'
          AND l.removal_reason = 'Spam detected'
    )
),
spam_actors AS (
    SELECT DISTINCT l.user_id
    FROM likes AS l
    WHERE l.reaction_status = 'removed'
      AND l.removal_reason = 'Spam detected'
),
q_cte AS (
    SELECT u.user_id, u.user_name, u.country, u.is_active
    FROM users AS u
    JOIN spam_actors AS s ON s.user_id = u.user_id
),
q_exists AS (
    SELECT u.user_id, u.user_name, u.country, u.is_active
    FROM users AS u
    WHERE EXISTS (
        SELECT 1
        FROM likes AS l
        WHERE l.user_id = u.user_id
          AND l.reaction_status = 'removed'
          AND l.removal_reason = 'Spam detected'
    )
),
differences AS (
    (SELECT * FROM q_in EXCEPT SELECT * FROM q_cte)
    UNION ALL
    (SELECT * FROM q_cte EXCEPT SELECT * FROM q_in)
    UNION ALL
    (SELECT * FROM q_in EXCEPT SELECT * FROM q_exists)
    UNION ALL
    (SELECT * FROM q_exists EXCEPT SELECT * FROM q_in)
)
SELECT COUNT(*) AS differing_rows
FROM differences;

-- this query compares all 3 queries and shows if there is differences among them in the result set
-- the result is 0 showing that all 3 queries returns the very same result.