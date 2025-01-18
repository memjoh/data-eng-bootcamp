create type actors_scd_type as (
	quality_class	quality_class,
	is_active		boolean,
	start_year		integer,
	end_year		integer
);


with last_year_scd as (
	select *
	from actors_history_scd
	where current_year = 2021
	and end_year = 2021
)

, historical_scd as (
	select
		actor,
		actorid,
		quality_class,
		is_active,
		start_year,
		end_year
	from actors_history_scd
	where current_year = 2021
	and end_year < 2021
)

, this_year_data as (
	select *
	from actors_history_scd
	where current_year = 2022
)

, unchanged_records as (
	select 
		ts.actor,
		ts.actorid,
		ts.quality_class,
		ts.is_active,
		ls.start_year,
		ts.current_year as end_year
	from this_year_data ts
	join last_year_scd ls
		on ls.actorid = ts.actorid
	where ts.quality_class = ls.quality_class
		and ts.is_active = ls.is_active
)

, changed_records as (
	select 
		ts.actor,
		ts.actorid,
		unnest(
			array[
				row(
					ls.quality_class,
					ls.is_active,
					ls.start_year,
					ls.end_year
				)::actors_scd_type,
				row(
					ts.quality_class,
					ts.is_active,
					ts.current_year,
					ts.current_year
				)::actors_scd_type
			]
		) as records
	from this_year_data ts
	left join last_year_scd ls
		on ls.actorid = ts.actorid
	where ts.quality_class <> ls.quality_class
		or ts.is_active <> ls.is_active
)

, unnested_changed_records as (
	select
		actor,
		actorid,
		(records::actors_scd_type).quality_class,
		(records::actors_scd_type).is_active,
		(records::actors_scd_type).start_year,
		(records::actors_scd_type).end_year
	from changed_records
)

, new_records as (
	select 
		ts.actor,
		ts.actorid,
		ts.quality_class,
		ts.is_active,
		ts.current_year as start_year,
		ts.current_year as end_year
	from this_year_data ts
	left join last_year_scd ls
		on ls.actorid = ts.actorid
	where ls.actorid is null
)

select *
from historical_scd

union all 

select *
from unchanged_records

union all 

select *
from unnested_changed_records

union all 

select *
from new_records

order by actorid, start_year
