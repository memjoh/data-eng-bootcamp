# Fact Data Modeling

## Fact Data Fundamentals

#### Core components
* something that happened or occurred (user logins, transaction, 'like')
* 10-100x the volume of dimension data
* duplicates are common
* context is needed for analysis 

#### Normalization vs Denormalization
* **Normalized** facts don't have any dimensional attributes, just IDs to join to get the information
* **Denormalized** facts bring in some dimensional attributes for quicker analysis at the cost of more storage
* the smaller the scale the better normalization will be

#### Fact Data vs Raw Logs
* **Raw logs** normally used by software eng, ugly schemas, quality errors, shorter retention
* **Fact data** cleaner column names, quality guarentees (uniqueness, not null, etc), longer retention, trusted
  
[lab sql](https://github.com/memjoh/data-eng-bootcamp/blob/4051111b1a9df7af918aee3e8e5f336ece057825/week2/lab/lab1_ddl_fct_game_details.sql)  &nbsp; | &nbsp;  [homework sql 1 dedupe](https://github.com/memjoh/data-eng-bootcamp/blob/4051111b1a9df7af918aee3e8e5f336ece057825/week2/homework/game_details_dedupe.sql)   &nbsp; | &nbsp;  [homework sql 2 ddl](https://github.com/memjoh/data-eng-bootcamp/blob/4051111b1a9df7af918aee3e8e5f336ece057825/week2/homework/user_devices_cumulated_ddl.sql)     &nbsp; | &nbsp;  [homework sql 3 ddl](https://github.com/memjoh/data-eng-bootcamp/blob/4051111b1a9df7af918aee3e8e5f336ece057825/week2/homework/hosts_cumulated_ddl.sql)    &nbsp; | &nbsp;  [homework sql 4 ddl](https://github.com/memjoh/data-eng-bootcamp/blob/4051111b1a9df7af918aee3e8e5f336ece057825/week2/homework/hosts_cumulated_ddl.sql)


## Date List Data Structure

* extremely efficient way to manage user growth
* imagine a cumulated schema like `users_cumulated`
    * user_id
    * date
    * dates_active - an array of all the recent days that a user was active
* turned into a structure like this
    * user_id, date, datelist_int
    * 32 | 2023-01-01 | 100000001000000010000000010000
    * where the 1s represent activity for 2023-01-01 - bit_position (zero indexed)

[lab sql datelist](https://github.com/memjoh/data-eng-bootcamp/blob/4051111b1a9df7af918aee3e8e5f336ece057825/week2/lab/lab2_datalist_datatype_users_cumulated.sql)  &nbsp; | &nbsp;  [homework sql datelist](https://github.com/memjoh/data-eng-bootcamp/blob/4051111b1a9df7af918aee3e8e5f336ece057825/week2/homework/datelist_int.sql) 


## Reducing Shuffle with Reduced Facts

#### Parallel and Shuffle
want to be Parallel - Shuffle is a bottleneck to parallel (all data needs to be on 1 machine instead of being able to be spread out)
* Extremely parallel - SELECT, FROM, WHERE
* Kind of parallel - GROUP BY, JOIN, HAVING
* Painfully not parallel - ORDER BY
</br></br>  
* Make GROUP BY more efficient by bucketing (based on a high cardinality key)
    * reduce data volume as much as you can

#### Reduced fact data modeling
* Fact data often has this scheme:
    * user_id, event_time, action, date_partition
    * very high volume, 1 row per event
* Daily aggregate often has this schema:
    * user_id, action_cnt, date_partition
    * medium size volume, 1 row per user per day
* Reduced fact takes this one step further:
    * user_id, action_cnt array, month_start_partition / year_start partition
    * low volume, 1 row per user per month or year
    * *not a monthly / yearly aggregate*
    * allows for fast correlation analysis between user-level metrics and dimensions; look at every single dimension quickly

[lab sql reduced facts array](https://github.com/memjoh/data-eng-bootcamp/blob/4051111b1a9df7af918aee3e8e5f336ece057825/week2/lab/lab3_reduced_facts_array_metrics.sql)   &nbsp; | &nbsp;  [lab sql reduced facts query](https://github.com/memjoh/data-eng-bootcamp/blob/4051111b1a9df7af918aee3e8e5f336ece057825/week2/lab/lab3_reduced_facts_array_metrics_query.sql) 
