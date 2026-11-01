
-- 3.1.1 : a active highly rated posts - the producers whose records
-- anchor the audit. Requirement: SELECT, WHERE, ORDER BY, LIMIT.
  select *  from posts where is_visible=true and like_count>300 order by post_id   limit 10;

-- 3.1.2 : all possible distinct  reaction_status - the events whose records
-- anchor the audit. Requirement: SELECT, WHERE ,DISTINCT,FROM
select distinct reaction_status from likes ; -- no there no more data that i expected

-- 3.1.3.1 :filter using a list of values dwell_ms - the event
-- anchor the audit. Requirement: SELECT,WHERE,FROM,BETWEEN
SELECT like_id, user_id, post_id, liked_at, dwell_ms
FROM likes
WHERE dwell_ms BETWEEN 1000 AND 5000;

-- 3.1.3.2 : filter using a list of values reaction_status - the event
-- anchor the audit. Requirement: SELECT,WHERE,FROM, IN
SELECT like_id, user_id, post_id, liked_at, reaction_status
FROM likes
WHERE reaction_status IN ('active','flagged' );

-- 3.1.4 : find name with likeliness pattern posts - the producers whose records
--  anchor the audit. Requirement: SELECT,WHERE,FROM,COALESCE,JOIN
SELECT po.post_id,COALESCE(po.post_title,'No Title Provided') As THE_TITLE,po.posted_on,
      COALESCE( po.author_country,'No Author Provided') As THE_AUTHOR,po.slug,po.like_count,
        COALESCE( li.unliked_at,CURRENT_TIMESTAMP) as TIME_OF_UNLIKING
FROM posts as po
join likes as li on po.post_id=li.post_id
WHERE po.post_title LIKE '%Post%';

-- 3.1.5 : a query with calculated/computed columns that would make sense
-- anchor the audit. Requirement: SELECT,WHERE,FROM,COALESCE,JOIN
SELECT
    l.like_id AS "Reaction ID",
    u.user_name AS "User",
    p.post_title AS "Post",
    l.liked_at AS "Reaction time",
    ROUND(l.dwell_ms / 1000.0, 1) AS "Time spent (seconds)",
    CASE
        WHEN l.dwell_ms < 1000 THEN 'Under 1 second'
        WHEN l.dwell_ms < 5000 THEN '1 to under 5 seconds'
        ELSE '5 seconds or more'
    END AS "Time spent category",
    COALESCE(
        NULLIF(TRIM(l.removal_reason), ''),
        'No reason provided'
    ) AS "Removal reason"
FROM likes AS l
JOIN users AS u ON u.user_id = l.user_id
JOIN posts AS p ON p.post_id = l.post_id;
