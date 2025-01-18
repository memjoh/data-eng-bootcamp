-- CREATE TABLE users_cumulated (
-- 	user_id		TEXT,
-- 	-- the list of dates in the past where the user was active
-- 	date_active	DATE[],
-- 	-- the current date for the user
-- 	date		DATE,
-- 	PRIMARY KEY	(user_id, date)
-- )

--INSERT INTO users_cumulated
-- WITH yesterday AS (
-- 	SELECT *
-- 	FROM users_cumulated
-- 	WHERE date = DATE('2023-01-30')
-- )

-- , today AS (
-- 	SELECT 
-- 		CAST(user_id AS TEXT) user_id,
-- 		DATE(CAST(event_time AS TIMESTAMP)) AS date_active
-- 	FROM events
-- 	WHERE DATE(CAST(event_time AS TIMESTAMP)) = DATE('2023-01-31')
-- 	AND user_id IS NOT NULL
-- 	GROUP BY user_id, DATE(CAST(event_time AS TIMESTAMP))
-- )

-- SELECT 
-- 	COALESCE(t.user_id, y.user_id) AS user_id,
-- 	CASE
-- 		WHEN y.date_active IS NULL
-- 			THEN ARRAY[t.date_active]
-- 		WHEN t.date_active IS NULL
-- 			THEN y.date_active
-- 		ELSE ARRAY[t.date_active] || y.date_active
-- 	END AS date_active,
--  -- want all dates here to be the same day
-- 	COALESCE(t.date_active, y.date + INTERVAL '1 day') AS date
-- FROM today t
-- FULL OUTER JOIN yesterday y
-- 	ON t.user_id = y.user_id


WITH users AS (
	SELECT * 
	FROM users_cumulated 
	WHERE date = DATE('2023-01-31')
)

, series AS (
	SELECT *
	FROM GENERATE_SERIES(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day')
		AS series_date
)

, placeholders AS (
	SELECT 
		CAST(
			CASE
				WHEN date_active @> ARRAY[DATE(series_date)]
					-- casts as 2 to the 32nd power to convert dates to integer values that are all powers of 2
					THEN CAST(POW(2, 32 - (date - DATE(series_date))) AS BIGINT)
				ELSE 0 
			END AS BIT(32)
		) placeholder_int_value, 
		*
	FROM users
	CROSS JOIN series
)

SELECT
	user_id,
	-- string of days with visit yes/no each day
	CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32)),
	-- sum of visits last 30 days
	BIT_COUNT(CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32))),
	BIT_COUNT(CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32))) > 0 AS dim_is_monthly_active,

	-- how many days were they active last 7
		-- '&' says anything 1 & 1 is 1 and anything 1 & 0 or 0 & 0 is 0
		-- anything after 7 days is 0, we don't care. but first 7 days will be 1 if active and 0 if not
		-- efficient! binary
	BIT_COUNT(
		CAST('111111100000000000000000000000' AS BIT(32)) &
			CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32))
	) > 0 AS dim_is_weekly_active,
	BIT_COUNT(
		CAST('100000000000000000000000000000' AS BIT(32)) &
			CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32))
	) > 0 AS dim_is_daily_active
FROM placeholders
GROUP BY user_id


