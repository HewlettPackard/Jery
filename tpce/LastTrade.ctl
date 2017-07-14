LOAD DATA INFILE '/tmp/jery/tables/LastTrade.txt'
TRUNCATE
INTO TABLE LAST_TRADE 
FIELDS TERMINATED BY '|'
(  LT_S_SYMB ,          
 LT_DTS TIMESTAMP "YYYY-MM-DD HH24:MI:SS.FF9" ,
 LT_PRICE ,
 LT_OPEN_PRICE ,
 LT_VOL        
)