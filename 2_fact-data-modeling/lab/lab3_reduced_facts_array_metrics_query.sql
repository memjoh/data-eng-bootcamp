WITH agg AS (
	SELECT 
		metric_name,
		month_start,
		ARRAY[
			SUM(metric_array[1]), 
			SUM(metric_array[2]), 
			SUM(metric_array[3])
		] AS summed_array
	FROM array_metrics
	GROUP BY metric_name, month_start
)

SELECT 
	metric_name,
	month_start + CAST(CAST(index - 1 AS TEXT) || ' day' AS INTERVAL),
	elem AS value
FROM agg
CROSS JOIN UNNEST(agg.summed_array) WITH ORDINALITY AS a(elem, index)