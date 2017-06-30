LOAD DATA INFILE '/tmp/jery/tables/StatusType.txt'
TRUNCATE
INTO TABLE STATUS_TYPE 
FIELDS TERMINATED BY '|'
(  ST_ID ,          
 ST_NAME        
)
