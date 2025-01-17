WITH deduped_events AS (
	SELECT
		user_id,
		url,
		event_time,
		DATE(event_time) AS event_date
	FROM events
	WHERE user_id IS NOT NULL
--	AND url IN ('/signup', '/api/v1/users', '/api/v1/user', '/api/v1/login')
	GROUP BY user_id, url, event_time, DATE(event_time)
)

, self_joined AS (
	SELECT 
		d1.user_id,
		d1.url,
		d2.url AS destination_url,
		d1.event_time,
		d2.event_time AS destination_event_time
	FROM deduped_events d1
	JOIN deduped_events d2
		ON d1.user_id = d2.user_id
			-- funnel measurement happens on same day
			AND d1.event_date = d2.event_date
			AND d2.event_time > d1.event_time
	--WHERE d1.url = '/signup'
	--AND d2.url IN ('/api/v1/users', '/api/v1/user', '/api/v1/login')
)

, user_level AS (
	SELECT 
		user_id,
		url,
		event_time,
		COUNT(
			DISTINCT 
				CASE 
					WHEN destination_url IN ('/api/v1/users', '/api/v1/user', '/api/v1/login')
						THEN destination_url
				END
		) AS converted,
		COUNT(1) AS number_of_hits
	FROM self_joined
	GROUP BY user_id, url, event_time
)

SELECT
	url,
	COUNT(1),
	SUM(converted) AS num_converted,
	CAST(SUM(converted) AS REAL) / COUNT(1) AS pct_converted,
	SUM(number_of_hits) AS num_hits,
	CAST(SUM(converted) AS REAL) / SUM(number_of_hits) AS hits_converted
FROM user_level
GROUP BY url
HAVING SUM(number_of_hits) > 400
ORDER BY 6 DESC