-- CREATE TABLE host_activity_reduced (
-- 	month					DATE,
-- 	host					TEXT,
-- 	hit_array				REAL[],
-- 	unique_visitors_array	REAL[],

-- 	PRIMARY KEY		(month, host)
-- )

INSERT INTO host_activity_reduced
WITH daily_aggregate AS (
	SELECT
		host,
		DATE(event_time) AS date,
		COUNT(1) AS num_site_hits,
		COUNT(DISTINCT user_id) AS num_unique_visitors
	FROM events
	WHERE DATE(event_time) = DATE('2023-01-03')
	AND user_id IS NOT NULL
	GROUP BY host, date
)

, yesterday_array AS (
	SELECT *
	FROM host_activity_reduced
	WHERE month = DATE('2023-01-01')
)

SELECT 
	COALESCE(ya.month, DATE_TRUNC('month', da.date)) AS month,
	COALESCE(da.host, ya.host) host,
	CASE
		WHEN ya.hit_array IS NOT NULL
			THEN ya.hit_array || ARRAY[COALESCE(da.num_site_hits, 0)]
		WHEN ya.hit_array IS NULL
			-- create array for every day from start of month to date and fill in with hit or 0
			THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)]) || ARRAY[COALESCE(da.num_site_hits, 0)]
	END AS hit_array,
	CASE
		WHEN ya.unique_visitors_array IS NOT NULL
			THEN ya.unique_visitors_array || ARRAY[COALESCE(da.num_unique_visitors, 0)]
		WHEN ya.unique_visitors_array IS NULL
			-- create array for every day from start of month to date and fill in with visitors or 0
			THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)]) || ARRAY[COALESCE(da.num_unique_visitors, 0)]
	END AS unique_visitors_array
FROM daily_aggregate da
FULL OUTER JOIN yesterday_array ya
	ON da.host = ya.host

ON CONFLICT (month, host)
DO
	UPDATE SET hit_array = EXCLUDED.hit_array;	
