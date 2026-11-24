-- Task 4.2: Build the breakdown leadership asked for
-- Leadership needs additional information that cannot be obtained from the basic grouping queries in Task 4.1. Complete the following three parts to produce more detailed analytical summaries.

-- Part A: Two numbers in one pass
-- For each producer, compute the total number of events and the total number of events classified as failures, in a single pass over the event table, without a WHERE clause filtering the whole query. The outliers here are the producers you will name in your finding.
--
-- ✓  CASE used inside an aggregate — for example SUM(CASE WHEN ... THEN 1 ELSE 0 END) or COUNT(CASE WHEN ... END).
--
-- ✓  Both totals appearing as separate columns in one result set.

SELECT
    p.post_id,
    p.post_title,
    COUNT(*) AS total_events,
    SUM(CASE
            WHEN l.reaction_status = 'flagged' THEN 1
            ELSE 0
        END) AS failure_events
FROM likes AS l
JOIN posts AS p ON p.post_id = l.post_id
GROUP BY p.post_id, p.post_title
ORDER BY failure_events DESC;

--Part B: Subtotals and a grand total
--The regional director wants subtotals per region and a platform grand total, not the detail rows. Write a query that produces regional subtotals and a platform-wide grand total without including the individual detail rows.
--✓  GROUP BY ROLLUP (...), or GROUPING SETS or CUBE.
--✓  A written note identifying which rows are the subtotals and which is the grand total.

SELECT
    CASE
        WHEN GROUPING(client_country) = 1 THEN 'PLATFORM GRAND TOTAL'
        ELSE client_country
    END AS region,
    COUNT(*) AS total_events,
    SUM(CASE WHEN reaction_status = 'flagged' THEN 1 ELSE 0 END)
        AS failure_events
FROM likes
GROUP BY ROLLUP (client_country)
HAVING GROUPING(client_country) = 1
    OR GROUPING(client_country) = 0
ORDER BY GROUPING(client_country), client_country;


-- Part C: A two-step pipeline
-- Leadership wants to establish a baseline for evaluating high-volume producers. That needs two steps: use a WITH clause to create an intermediate result that summarizes performance for each producer, then use a second aggregation or filter on that intermediate result to calculate a baseline for high-volume producers.
--
-- ✓  A WITH clause producing an intermediate aggregate.
--
-- ✓  A second aggregation or filter applied to that intermediate result.

WITH post_performance AS (
    SELECT
        post_id,
        COUNT(*) AS event_count,
        SUM(CASE
                WHEN reaction_status = 'flagged' THEN 1
                ELSE 0
            END) AS failure_events
    FROM likes
    GROUP BY post_id
)
SELECT
    COUNT(*) AS high_volume_posts,
    ROUND(
        AVG(100.0 * failure_events / NULLIF(event_count, 0)),
        2
    ) AS baseline_avg_failure_rate_pct
FROM post_performance
WHERE event_count >= 18;




-- Write up
-- For Part A, state the two questions your conditional aggregation answers side by side.
--
-- For Part B, name the reader who needs subtotals rather than detail rows, and say what decision the grand total supports that the group rows do not.
--
-- For Part C, state the question the pipeline answers.

