LOAD DATA INFILE '/tmp/jery/tables/WatchList.txt'
TRUNCATE
INTO TABLE WATCH_LIST 
FIELDS TERMINATED BY '|'
(  WL_ID ,          
 WL_C_ID        
)
