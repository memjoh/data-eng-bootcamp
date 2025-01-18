create table actors_history_scd (
	actor			text,
	actorid			text,
	quality_class	quality_class,
	is_active		boolean,
	start_year		integer,
	end_year		integer,
 	current_year	integer,

	primary key		(actorid, start_year)
);


insert into actors_history_scd
with with_previous as (
	select 
		actor,
		actorid,
		year,
		quality_class,
		coalesce(is_active,false) is_active,
		lag(quality_class, 1) over (partition by actorid order by year) as previous_quality_class,
		lag(coalesce(is_active,false), 1) over(partition by actorid order by year) as previous_is_active
	from actors 
	where year <= 2021
)

, with_indicators as (
select *,
	case
		when quality_class <> previous_quality_class then 1
		when is_active <> previous_is_active then 1
	else 0 end
	as change_indicator,
	case
		when is_active <> previous_is_active
			then 1 else 0 end
	as is_active_change_indicator
from with_previous
)

, with_streaks as (
	select 
		*,
		sum(change_indicator)
                over (partition by actorid order by year) as streak_identifier
	from with_indicators
)

select
	actor,
	actorid,
	quality_class,
	is_active,
	min(year) as start_year,
	max(year) as end_year,
	2021 as current_year
from with_streaks
group by actor, actorid, streak_identifier, quality_class, is_active
order by actor, streak_identifier;
