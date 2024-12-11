--create type array for films
create type films as (
	film	TEXT,
	votes	INTEGER,
	rating	REAL,
	filmid	TEXT
);

-- create class based on avg rating
create type quality_class as 
	enum('star', 'good', 'average', 'bad');

create table actors (
	actor			text,
	actorid			text,
 	year			integer,
	films			films[],
	quality_class	quality_class,
	is_active		boolean,

	primary key		(actorid, year)
);


insert into actors
with previous_year as (
	select *
	from actors
	where year = 2020
)

, current_year as (
	select 
		actor,
		actorid,
		year,
		array_remove(
		array_agg(
			row(
				film,
				votes,
				rating::real,
				filmid
			)::films
		), null) as films,
		avg(rating) as yearly_average_rating
	from actor_films 
	where year = 2021
	group by actor, actorid, year
)

select
	coalesce(cy.actor, py.actor) as actor,
	coalesce(cy.actorid, py.actorid) as actorid,

	coalesce(cy.year, py.year+1) as current_year,

	case 
		when py.year is null
			then cy.films
		when cy.year is not null 
			then py.films || cy.films
		else py.films
	end as films,

	coalesce(
		case 
			when cy.yearly_average_rating > 8 then 'star' 
			when cy.yearly_average_rating > 7 then 'good' 
			when cy.yearly_average_rating > 6 then 'average' 
			when cy.yearly_average_rating <=6 then 'bad' 
		end::quality_class,
	py.quality_class) as quality_class,

	cy.year = coalesce(cy.year, py.year+1) as is_active

from current_year cy
full outer join previous_year py
	on cy.actorid = py.actorid
