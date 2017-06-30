LOAD DATA INFILE '/tmp/jery/tables/Exchange.txt'
TRUNCATE
INTO TABLE EXCHANGE 
FIELDS TERMINATED BY '|'
(  EX_ID ,          
 EX_NAME ,
 EX_NUM_SYMB ,
 EX_OPEN ,
 EX_CLOSE ,
 EX_DESC ,
 EX_AD_ID        
)
