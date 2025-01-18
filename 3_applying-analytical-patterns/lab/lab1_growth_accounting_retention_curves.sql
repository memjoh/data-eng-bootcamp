-- CREATE TABLE users_growth_accounting (
-- 	user_id	   				TEXT,
-- 	first_active_date		DATE,
-- 	last_active_date		DATE,
-- 	daily_active_state		TEXT,
-- 	weekly_active_state		TEXT,
-- 	dates_active			DATE[],
-- 	date					DATE,
	
-- 	PRIMARY KEY				(user_id, date)
-- );

INSERT INTO users_growth_accounting
WITH yesterday AS (
	SELECT *
	FROM users_growth_accounting
	WHERE date = DATE('2023-01-16')
)

, today AS (
	SELECT
		user_id::TEXT user_id,
		DATE_TRUNC('day', event_time::timestamp) AS today_date,
		COUNT(1)
	FROM events
	WHERE DATE_TRUNC('day', event_time::timestamp) = DATE('2023-01-17')
	AND user_id IS NOT NULL
	GROUP BY user_id, DATE_TRUNC('day', event_time::timestamp)
)

SELECT 
	COALESCE(t.user_id, y.user_id) AS user_id,
	COALESCE(y.first_active_date, t.today_date)::DATE AS first_active_date,
	COALESCE(t.today_date, y.last_active_date)::DATE AS last_active_date,
	CASE
		-- not in data before today
		WHEN y.user_id IS NULL AND t.user_id IS NOT NULL
			THEN 'New'
		-- active yesterday and today
		WHEN y.last_active_date = t.today_date - INTERVAL '1 day'
			THEN 'Retained'
		-- active today, last active date was before yesterday
		WHEN y.last_active_date < t.today_date - INTERVAL '1 day'
			THEN 'Resurrected'
		-- not active today, last active date in past
		WHEN t.today_date IS NULL AND y.last_active_date = y.date
			THEN 'Churned'
		ELSE 'Stale'
	END AS daily_active_state,
	CASE
		-- not in data before today
		WHEN y.user_id IS NULL AND t.user_id IS NOT NULL
			THEN 'New'
		-- active today, last active date was more than 7 days ago
		WHEN y.last_active_date < t.today_date - INTERVAL '7 day'
			THEN 'Resurrected'
		-- not active today, last active date 7 days in past
		WHEN t.today_date IS NULL AND y.last_active_date = y.date - INTERVAL '7 day'
			THEN 'Churned'
		-- active within last 7 days
		WHEN COALESCE(t.today_date, y.last_active_date) + INTERVAL '7 day' >= y.date
			THEN 'Retained'
		ELSE 'Stale'
	END AS weekly_active_state,
	COALESCE(y.dates_active, ARRAY[]::DATE[]) ||
		CASE
			WHEN t.user_id IS NOT NULL
				THEN ARRAY[t.today_date::DATE]
			ELSE ARRAY[]::DATE[]
	END AS dates_active,
	COALESCE(t.today_date, y.date + INTERVAL '1 day')::DATE AS date
FROM today t
FULL OUTER JOIN yesterday y
	ON t.user_id = y.user_id


-- cohort analysis query
SELECT 
	date - first_active_date AS days_since_first_active,
	COUNT(
		CASE
			WHEN daily_active_state IN ('Retained', 'Resurrected', 'New')
			THEN 1 END
	) AS number_active,
	COUNT(*),
	CAST(
		COUNT(
			CASE
				WHEN daily_active_state IN ('Retained', 'Resurrected', 'New')
				THEN 1 END
		) AS REAL
	) / COUNT(*) AS perc_active
FROM users_growth_accounting
--WHERE first_active_date = DATE('2023-01-01')
GROUP BY 1
ORDER BY 1