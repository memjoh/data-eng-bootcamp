-- PART 1 LAB

-- create type for stats structure
create type season_stats as (
	season 	integer,
	gp 		integer,
	pts 	real,
	reb 	real,
	ast 	real
)

-- create type for class dimension with specific values
create type scoring_class as
	enum('star', 'good', 'average', 'bad');

-- create base for players table
create table players (
	player_name 	text,
	height			text,
	college			text,
	country			text,
	draft_year		text,
	draft_round		text,
	draft_number	text,
	
	season_stats	season_stats[],
 	scoring_class	scoring_class,
 	years_since_last_season	integer,
	current_season	integer,
	
	primary key (player_name, current_season)
)

-- manually update yesterday and today year filters year by year to ingest full history
insert into players 
with yesterday as (
	select * from players
	where current_season = 2000
)

, today as (
	select * from player_seasons
	where season = 2001
)

select
	coalesce(t.player_name, y.player_name) as player_name,
	coalesce(t.height, y.height) as height,
	coalesce(t.college, y.college) as college,
	coalesce(t.country, y.country) as country,
	coalesce(t.draft_year, y.draft_year) as draft_year,
	coalesce(t.draft_round, y.draft_round) as draft_round,
	coalesce(t.draft_number, y.draft_number) as draft_number,

	case 
		when y.season_stats is null
			then array[
				row(
					t.season,
					t.gp,
					t.pts,
					t.reb,
					t.ast
				)::season_stats
			]
		when t.season is not null 
			then y.season_stats || array[
				row(
					t.season,
					t.gp,
					t.pts,
					t.reb,
					t.ast
				)::season_stats
		]
		else y.season_stats
	end as season_stats,

	case
		when t.season is not null
			then 
				case
					when t.pts > 20 then 'star'
					when t.pts > 15 then 'good'
					when t.pts > 10 then 'average'
					else 'bad'
				end::scoring_class
			else y.scoring_class
	end as scoring_class,

	case
		when t.season is not null
			then 0
		else y.years_since_last_season + 1
	end as years_since_last_season,

	coalesce(t.season, y.current_season+1) current_season

from today t
full outer join yesterday y
	on t.player_name = y.player_name;


-- example analytics queries (1)

with unnested as (
	select
		player_name,
		unnest(season_stats)::season_stats as season_stats
	from players
	where player_name = 'Michael Jordan'
	and current_season = 2001
)

select
	player_name,
	(season_stats::season_stats).*
from unnested 


-- example analytics queries (2 and 3)

select
	player_name,
	season_stats[1] as first_season,
	season_stats[cardinality(season_stats)] as latest_season
from players
where player_name= 'Michael Jordan'
and current_season = 2001

select
	player_name,
	
	(season_stats[cardinality(season_stats)]::season_stats).pts as latest_season_pts,
	(season_stats[1]::season_stats).pts as first_season_pts,

	(season_stats[cardinality(season_stats)]::season_stats).pts /
	case 
		when (season_stats[1]::season_stats).pts = 0 
			then 1 
		else (season_stats[1]::season_stats).pts 
	end as pts_improvement_perc
	
from players
where current_season = 2001