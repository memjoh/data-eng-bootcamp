# Lego Database Creation for Analysis

[raw data from Lego](https://www.kaggle.com/datasets/rtatman/lego-database)  
_data over time since 1950 : inventory parts > by color > parts laddering up to sets > sets laddering up to themes_  
1. created a database, schemas and tables
2. explored data and created views and datasets for analysis
3. created explanatory visualizations

   
### Tech Stack Used
**PostgreSQL &nbsp;&nbsp; | &nbsp;&nbsp; pgAdmin &nbsp;&nbsp; | &nbsp;&nbsp; TablePlus &nbsp;&nbsp; | &nbsp;&nbsp; Hex &nbsp;&nbsp; | &nbsp;&nbsp; Tableau**  
<br />  
![image](https://github.com/user-attachments/assets/32dfa55c-709c-4f49-82d3-b5f19b5f683a)
<br />   

## 1a • Set Up Database
* Installed [PostgreSQL](https://www.postgresql.org/download/)
* Created new database and staging schema
* Imported [Initial Raw Data](https://www.kaggle.com/datasets/rtatman/lego-database) using SQL script to build tables
* Created new user with Select access to contents of the database
* Connected the database to TablePlus for later querying and analysis  

**Reference**  
[Local PostgreSQL Setup](https://www.youtube.com/watch?v=QPE5_p9PRsc)  
<br />    

## 1b • Create Schemas and Tables
[Schema Scripts](table_creation.sql)  
[Schema Diagram (ERD)](lego_er_diagram.png)  
<br />    

## 2 • Data Analysis
Questions asked:
* How many sets contain 'unique pieces' (pieces not used in any other set) and how has this changed over time?
* Are these 'unique pieces' more likely to be 'odd' colors?
* Have the colors and variety of colors changed over time?
<br />

[View Creation Script](view_creation.sql)  
<br />

## 3 • Data Visualization
