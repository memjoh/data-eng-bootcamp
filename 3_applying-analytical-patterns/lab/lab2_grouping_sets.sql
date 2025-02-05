-- CREATE TABLE device_hits_dashboard AS

-- WITH events_augmented AS (
-- 	SELECT
-- 		COALESCE(d.os_type, 'unknown') AS os_type,
-- 		COALESCE(d.device_type, 'unknown') AS device_type,
-- 		COALESCE(d.browser_type, 'unknown') AS browser_type,
-- 		url,
-- 		user_id
-- 	FROM events e
-- 		JOIN devices d
-- 			ON e.device_id = d.device_id
-- )

-- -- -- old way of grouping; would need to union all to get additional cuts
-- -- SELECT 
-- -- 	os_type,
-- -- 	device_type,
-- -- 	browser_type,
-- -- 	COUNT(1)
-- -- FROM events_augmented
-- -- GROUP BY os_type, device_type, browser_type
-- -- ORDER BY COUNT(1) DESC

-- SELECT 
-- 	-- helper columns to see which are included in aggregations
-- 	-- GROUPING(os_type),
-- 	-- GROUPING(device_type),
-- 	-- GROUPING(browser_type),
-- 	CASE
-- 		WHEN GROUPING(os_type) = 0 
-- 			AND GROUPING(device_type) = 0 
-- 			AND GROUPING(browser_type) = 0 
-- 		THEN 'os_type__device_type__browser'
-- 		WHEN GROUPING(os_type) = 0 THEN 'os_type'
-- 		WHEN GROUPING(device_type) = 0 THEN 'device_type'
-- 		WHEN GROUPING(browser_type) = 0 THEN 'browser_type'
-- 	END AS aggregation_level,
-- 	COALESCE(os_type, '(overall)') AS os_type,
-- 	COALESCE(device_type, '(overall)') AS device_type,
-- 	COALESCE(browser_type, '(overall)') AS browser_type,
-- 	COUNT(1)
-- FROM events_augmented
-- GROUP BY GROUPING SETS(
-- 	(browser_type, device_type, os_type),
-- 	(browser_type),
-- 	(os_type),
-- 	(device_type)
-- )
-- ORDER BY COUNT(1) DESC


SELECT *
FROM device_hits_dashboard
WHERE aggregation_level = 'os_type'