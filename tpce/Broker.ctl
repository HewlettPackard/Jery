LOAD DATA INFILE '/tmp/jery/tables/Broker.txt'
TRUNCATE
INTO TABLE BROKER 
FIELDS TERMINATED BY '|'
(  B_ID ,          
 B_ST_ID ,
 B_NAME ,
 B_NUM_TRADES ,
 B_COMM_TOTAL        
)
