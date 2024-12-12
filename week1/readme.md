# Data Dimensional Modeling

## Cumulative Table Design

#### Core components
1. Daily state table for today with daily metrics, GROUP BY identifiers
2. Cumulative data from yesterday

* FULL OUTER JOIN the 2 dataframes together
* COALESCE values to keep everything
* Hangs on to all history without having to scan all of it

#### Strengths
* Historical analysis without shuffle
* Easy 'transition' analysis

#### Drawbacks
* Can only be backfilled sequentially
* Handling PII data can be a mess since deleted / inactive users get carried forward
  
[lab sql](https://github.com/memjoh/data-eng-bootcamp/blob/fdf8e0cc246970e9f6550c360ea0f5ce26141a87/week1/lab/lab1_cumulative_table_players.sql)  &nbsp; | &nbsp;  [homework sql](https://github.com/memjoh/data-eng-bootcamp/blob/fdf8e0cc246970e9f6550c360ea0f5ce26141a87/week1/homework/actors.sql)  

for more see: https://github.com/DataExpert-io/cumulative-table-design  

_Additional topics discussed: Temporal cardinality | Parquet compression format_  


## Slowly Changing Dimensions

#### Idempotent pipelines - critical!

pipelines should produce the same results regardless of:
* the day it's run
* how many times it's run
* the hour that it's run

troubleshooting non-idempotent pipelines is hard because you get data inconsistencies depending on when the table was run; data is not reproducible

#### Slowly changing dimensions

dimensions that change over time, e.g. age

SCD Types:
* Type 0 : aren't actually slowly changing (e.g. birth date); are idempotent if true
* Type 1 : latest value; should never be used since it makes pipelines not idempotent anyore
* Type 2 : gold standard, purely idempotent; have a START_DATE and END_DATE; be cautious, there is more than 1 row per dimension
* Type 3 : only hold on to 'original' and 'current' value, history is lost in between  

[lab sql setup](https://github.com/memjoh/data-eng-bootcamp/blob/main/week1/lab/lab2_cumulative_table_setup_players.sql)  &nbsp; | &nbsp;  [lab sql scd](https://github.com/memjoh/data-eng-bootcamp/blob/main/week1/lab/lab2_slowly_changing_dimension_players_scd.sql)  &nbsp; | &nbsp;  [lab sql scd incremental update](https://github.com/memjoh/data-eng-bootcamp/blob/main/week1/lab/lab2_slowly_changing_dimension_incremental_update_players_scd.sql)  &nbsp; | &nbsp;  [homework sql scd](https://github.com/memjoh/data-eng-bootcamp/blob/main/week1/homework/actors_history_scd.sql)  &nbsp; | &nbsp;  [homework sql scd incremental update](https://github.com/memjoh/data-eng-bootcamp/blob/fdf8e0cc246970e9f6550c360ea0f5ce26141a87/week1/homework/actors_history_scd_incremental.sql)  



## Additive vs non-additive dimensions

#### Additives
* dimension is mutually exclusive (add up to total number)
* can use count instead of having to use count distinct
  
#### Enums
* don’t use if ~ >50 options
* can up-level your data quality automatically, built in static fields, built in documentation
* examples: notification channel (push, in-app, etc)
* if you have an exhaustive list of an enum, you can use as sub-partitions and chunk up a big data problem into manageable pieces


[lab sql](https://github.com/memjoh/data-eng-bootcamp/blob/fdf8e0cc246970e9f6550c360ea0f5ce26141a87/week1/lab/lab3_enums_vertices_edges.sql) 

_Additional topics discussed: Enums | Flexible data types | Graph data modeling_
