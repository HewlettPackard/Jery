LOAD DATA INFILE '/tmp/jery/tables/CompanyCompetitor.txt'
TRUNCATE
INTO TABLE COMPANY_COMPETITOR
FIELDS TERMINATED BY '|'
(  CP_CO_ID ,          
 CP_COMP_CO_ID ,
 CP_IN_ID        
)
