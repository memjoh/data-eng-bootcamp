-- CREATE TABLE user_devices_cumulated (
-- 	user_id						NUMERIC,
-- 	browser_type				TEXT,
-- 	-- the list of dates in the past where the user was active on that browser_type
-- 	device_activity_datelist	DATE[],
-- 	-- the current date for the user
-- 	date						DATE,
	
-- 	PRIMARY KEY		(user_id, browser_type, date)
-- )


INSERT INTO user_devices_cumulated
WITH yesterday AS (
	SELECT *
	FROM user_devices_cumulated
	WHERE date = DATE('2023-01-30')
)

, today AS (
	SELECT 
		a.user_id, 
		COALESCE(b.browser_type, 'unknown') AS browser_type, 
		DATE(CAST(a.event_time AS TIMESTAMP)) AS device_activity_datelist
	FROM events a
	LEFT JOIN devices b
		ON a.device_id = b.device_id
	WHERE DATE(CAST(a.event_time AS TIMESTAMP)) = DATE('2023-01-31')
		AND a.user_id IS NOT NULL
	GROUP BY a.user_id, 
		b.browser_type, 
		DATE(CAST(a.event_time AS TIMESTAMP))
)

SELECT 
	COALESCE(t.user_id, y.user_id) AS user_id,
	COALESCE(t.browser_type, y.browser_type) AS browser_type,
	CASE
		WHEN y.device_activity_datelist IS NULL
			THEN ARRAY[t.device_activity_datelist]
		WHEN t.device_activity_datelist IS NULL
			THEN y.device_activity_datelist
		ELSE ARRAY[t.device_activity_datelist] || y.device_activity_datelist
	END AS device_activity_datelist,
 -- want all dates here to be the same day
	COALESCE(t.device_activity_datelist, y.date + INTERVAL '1 day') AS date
FROM today t
FULL OUTER JOIN yesterday y
	ON t.user_id = y.user_id
	AND t.browser_type = y.browser_type


