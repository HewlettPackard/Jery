LOAD DATA INFILE '/tmp/jery/tables/Company.txt'
TRUNCATE
INTO TABLE COMPANY 
FIELDS TERMINATED BY '|'
(  CO_ID ,          
 CO_ST_ID ,
 CO_NAME ,
 CO_IN_ID ,
 CO_SP_RATE ,
 CO_CEO ,
 CO_AD_ID ,
 CO_DESC ,
 CO_OPEN_DATE DATE "YYYY-MM-DD"       
)