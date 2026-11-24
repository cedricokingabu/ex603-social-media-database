--Task 4.1 — the baseline, per-producer, HAVING, and two-dimension queries.

--1. Calculate the following statistics across the entire event table using your theme's metric: the count, total, average, minimum, and maximum of your theme’s metric across the whole event table, and how many distinct actors appear. Review your results carefully. For example, if your metric should never be zero but your minimum value is zero, this may indicate another data-quality issue that needs investigation.

    SELECT
    COUNT(*)                AS event_count,
    SUM(dwell_ms)      AS metric_total,
    AVG(dwell_ms)      AS metric_average,
    MIN(dwell_ms)      AS metric_minimum,
    MAX(dwell_ms)      AS metric_maximum,
    COUNT(DISTINCT user_id) AS distinct_actors
FROM likes;

--2. Write a query that calculates the event count and average metric for each producer. Sort the results from the producer with the most events to the producer with the fewest. Consider what these results tell you about differences in activity and performance across producers.
SELECT
    post_id,
    COUNT(*)       AS event_count,
    ROUND(AVG(dwell_ms) ) AS average_metric
FROM likes
GROUP BY post_id
ORDER BY event_count DESC;

--3. Which producers have enough volume for their rate to mean anything?
-- A producer with only a few events may have a high failure rate that is not representative
-- of their usual performance. Choose a minimum event-count threshold and use HAVING
-- to include only producers who meet that threshold. Explain why you selected
-- your threshold.
SELECT
    p.post_id,
    p.post_title,
    COUNT(l.like_id) AS like_events,
    COUNT(l.like_id) FILTER (WHERE l.unliked_at IS NOT NULL) AS removed_likes,
    ROUND(
        100.0 * COUNT(l.like_id) FILTER (WHERE l.unliked_at IS NOT NULL)
        / NULLIF(COUNT(l.like_id), 0),
        2
    ) AS removed_like_rate_pct
FROM posts AS p
JOIN likes AS l ON l.post_id = p.post_id
GROUP BY p.post_id, p.post_title
HAVING COUNT(l.like_id) >= 12
ORDER BY removed_like_rate_pct DESC;

--I chose 12 events as a practical exploratory cutoff to exclude posts with very small samples; it is not a universal statistical rule. Confirm what counts as a “failure” before interpreting the rate—the schema doesn’t define that. If the intended threshold is the stored posts.like_count instead, use HAVING MAX(p.like_count) >= 12; that field may not equal the number of rows in likes.

--4. How does the picture change along two dimensions at once?
-- Leadership also wants to understand how performance varies across regions.
-- Write a query that groups the data by two dimensions, including region,
-- and calculates the relevant summary statistics. Your results should contain
-- one row for each combination of the two dimensions so that regional leaders
-- can review their results.

SELECT
    client_country AS region,
    reaction_status,
    COUNT(*) AS event_count,
    ROUND(AVG(dwell_ms)) AS average_dwell_ms,
    MIN(dwell_ms) AS minimum_dwell_ms,
    MAX(dwell_ms) AS maximum_dwell_ms
FROM likes
GROUP BY client_country, reaction_status
ORDER BY region, reaction_status;
