LOAD DATA INFILE '/tmp/jery/tables/WatchItem.txt'
TRUNCATE
INTO TABLE WATCH_ITEM 
FIELDS TERMINATED BY '|'
(  WI_WL_ID ,          
 WI_S_SYMB        
)
