WITH user_devices AS (
	SELECT * 
	FROM user_devices_cumulated 
	-- temporary filter for 1 date only
	WHERE date = DATE('2023-01-31')
)

, series AS (
	SELECT *
	-- generate all days for the month
	FROM GENERATE_SERIES(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day')
		AS series_date
)

, placeholders AS (
	SELECT 
		CAST(
			CASE
				WHEN device_activity_datelist @> ARRAY[DATE(series_date)]
					-- casts as 2 to the 32nd power to convert dates to integer values that are all powers of 2
					THEN CAST(POW(2, 32 - (date - DATE(series_date))) AS BIGINT)
				ELSE 0 
			END AS BIT(32)
		) placeholder_int_value, 
		*
	FROM user_devices
	CROSS JOIN series
)

SELECT
	user_id,
	browser_type,
	-- string of days with visit yes/no each day
	CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32)) AS datelist_int,
	-- sum of visits last 30 days
	BIT_COUNT(CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32))) device_activity_day_count,
	BIT_COUNT(CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32))) > 0 AS dim_is_monthly_active,

	-- how many days were they active last 7
		-- '&' says anything 1 & 1 is 1 and anything 1 & 0 or 0 & 0 is 0
		-- anything after 7 days is 0, we don't care. but first 7 days will be 1 if active and 0 if not
	BIT_COUNT(
		CAST('111111100000000000000000000000' AS BIT(32)) &
			CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32))
	) > 0 AS dim_is_weekly_active,
	BIT_COUNT(
		CAST('100000000000000000000000000000' AS BIT(32)) &
			CAST(CAST( SUM(CAST(placeholder_int_value AS BIGINT)) AS BIGINT) AS BIT(32))
	) > 0 AS dim_is_daily_active
FROM placeholders
GROUP BY user_id, browser_type