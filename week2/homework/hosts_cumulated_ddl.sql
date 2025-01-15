-- CREATE TABLE hosts_cumulated (
-- 	host					TEXT,
-- 	-- the list of dates in the past where the host was active
-- 	host_activity_datelist	DATE[],
-- 	-- the current date for the host
-- 	date					DATE,

-- 	PRIMARY KEY				(host, date)
-- )

INSERT INTO hosts_cumulated
WITH yesterday AS (
	SELECT *
	FROM hosts_cumulated
	WHERE date = DATE('2023-01-30')
)

, today AS (
	SELECT 
		host,
		DATE(CAST(event_time AS TIMESTAMP)) AS date_active
	FROM events
	WHERE DATE(CAST(event_time AS TIMESTAMP)) = DATE('2023-01-31')
	GROUP BY host, DATE(CAST(event_time AS TIMESTAMP))
)

SELECT 
	COALESCE(t.host, y.host) AS host,
	CASE
		WHEN y.host_activity_datelist IS NULL
			THEN ARRAY[t.date_active]
		WHEN t.date_active IS NULL
			THEN y.host_activity_datelist
		ELSE ARRAY[t.date_active] || y.host_activity_datelist
	END AS host_activity_datelist,
 -- want all dates here to be the same day
	COALESCE(t.date_active, y.date + INTERVAL '1 day') AS date
FROM today t
FULL OUTER JOIN yesterday y
	ON t.host = y.host
