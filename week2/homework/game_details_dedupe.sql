-- Find and delete duplicates from game_details

-- check for duplicates
SELECT game_id, player_id 
FROM game_details 
GROUP BY game_id, player_id 
HAVING COUNT(*)>1;

-- delete duplicates
DELETE FROM game_details
WHERE ctid IN (
	SELECT ctid FROM (
		SELECT *, ctid,
			ROW_NUMBER() OVER(PARTITION BY game_id, player_id ORDER BY ctid DESC) AS rownum
		FROM game_details
	) WHERE rownum > 1
);

