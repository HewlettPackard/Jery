LOAD DATA INFILE '/tpce/Exchange.txt'
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