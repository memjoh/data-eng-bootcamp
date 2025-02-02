CREATE OR REPLACE VIEW analysis.vw_unique_parts AS (

WITH unique_parts AS (
	SELECT
		p.part_num AS unique_part_flag
	FROM analysis.parts p 
	JOIN analysis.inventory_parts ip ON p.part_num = ip.part_num
	JOIN analysis.inventories i ON i.id = ip.inventory_id
	JOIN analysis.sets s ON s.set_num = i.set_num 
	GROUP BY p.part_num
	HAVING COUNT(*)=1
)

, base AS (
	SELECT
		p.part_num,
		p.name AS part_name,
		CASE
			WHEN up.unique_part_flag IS NULL THEN 'not unique'
			ELSE 'unique'
		END AS unique_part_flag,
		s.name AS set_name,
		s.year AS set_year,
		t.name AS theme_name,
		c.rgb
	FROM analysis.parts p 
	LEFT JOIN unique_parts up ON up.unique_part_flag = p.part_num 
	JOIN analysis.inventory_parts ip ON p.part_num = ip.part_num
	JOIN analysis.inventories i ON i.id = ip.inventory_id
	JOIN analysis.sets s ON s.set_num = i.set_num 
	JOIN analysis.themes t ON t.id = s.theme_id 
	JOIN analysis.colors c ON c.id = ip.color_id 
)

SELECT 
	theme_name,
	set_name,
	set_year,
	rgb,
	COUNT(
		CASE 
			WHEN unique_part_flag = 'unique'
			THEN part_num 
	END) AS unique_part_count,
	COUNT(part_num) as total_parts
FROM base
GROUP BY 1,2,3,4

);
