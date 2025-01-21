# Applying Analytical Patterns

## Growth Accounting, Survivor Analysis, Window-Based Analysis

#### Aggregation-based
- simplest and most common
- all about GROUP BY
- upstream dataset is often the “daily metrics”
- trend analysis, root cause analysis, composition
- gotchas:
    - think about combinations that matter the most, don’t bring in too many dimensions that aren’t needed (or just back to daily data table)
    - be careful looking at many-combination, long-tie frame analyses (>90 days)

#### Cumulation-based
- Time is a significantly different dimension vs other ones
    - care a lot about state today vs state of yesterday and what’s changed
- FULL OUTER JOIN used here (built on top of cumulative tables)
    - need to keep track of when there isn’t data (didn’t do something)
- State transition tracking and Retention (also called j curves, survivor analysis)
- Growth accounting
    - special version of state transition track
        - new (didn’t exist yesterday, active today)
        - retained (active yesterday, active today)
        - churned (active yesterday, inactive today)
        - resurrected (inactive yesterday, active today)
        - stale (inactive yesterday, inactive today)

#### Window-based
- DoD / WoW / MoM / YoY - rate of change over a period of time
- Rolling Sum / Average
- Ranking
- FUNCTION() OVER (PARTITION BY keys ORDER BY sort ROWS BETWEEN n PRECEDING AND CURRENT ROW)
  
[lab sql retention curves](https://github.com/memjoh/data-eng-bootcamp/blob/ea318afdcbb699dc32f7c399c48030426dc9b8ba/3_applying-analytical-patterns/lab/lab1_growth_accounting_retention_curves.sql) 


## Advanced SQL, Funnels

#### Grouping sets 
````
FROM events_augmented
GROUP BY GROUPING SETS (
	(os_type, device_type, browser_type),
	(os_type, browser_type),
	(os_type),
	(browser_type)
)
````
- 4 queries in one
- when grouping by browser_type for example it will nullify all other groups
    - best practice - ensure there are no nulls to begin with (coalesce everything before)
- would otherwise have to write these all separately and union together
    - performance benefits - UNION ALL very slow
    - readability and maintainability benefits
- most control over what groups you want calculated (why use CUBE that provides 8 different groups if you only need these 4 groups)

#### Cube
````
FROM events_augmented
GROUP BY CUBE(os_type, device_type, browser_type)
````
- gives all possible permutations
- for above example - gives combination of all 3, then combo of 2’s, then combo of 1’s, then 0
- can lead to problems if you pick more than needed (exponentially increases) or it does combinations that you really don’t need; probably don’t use on more than 3 combinations

#### Rollup
````
FROM events_augmented
GROUP BY ROLLUP(os_type, device_type, browser_type)
````
- use for hierarchical data (like country > state > city)
- used more often than CUBE

#### Window Functions
- the **function** - RANK, SUM, AVG, DENSE_RANK, ROW_NUMBER
    - probably no use cases where you’d use RANK (1, 2, 2, 4) vs ROW_NUMBER (1, 2, 3, 4) vs DENSE_RANK (1, 2, 2, 3)
- the **window** - PARTITION BY, ORDER BY, ROWS
    - ROWS defaults to current row + all previous

#### Symptoms of Bad Data Modeling
- slow dashboards
- queries with a weird number of CTEs (maybe another step in the middle that should be materialized as a temp/staging table)
- lots of CASE WHEN statements in the analytics queries
- remember - your job as a data engineer to make sure you’re making the analysts job as clear and simple as possible

[lab sql funnel analysis](https://github.com/memjoh/data-eng-bootcamp/blob/ea318afdcbb699dc32f7c399c48030426dc9b8ba/3_applying-analytical-patterns/lab/lab2_funnel_analysis.sql)  &nbsp; | &nbsp;  [lab sql grouping sets](https://github.com/memjoh/data-eng-bootcamp/blob/ea318afdcbb699dc32f7c399c48030426dc9b8ba/3_applying-analytical-patterns/lab/lab2_grouping_sets.sql) 
