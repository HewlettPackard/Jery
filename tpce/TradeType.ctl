LOAD DATA INFILE '/tmp/jery/tables/TradeType.txt'
TRUNCATE
INTO TABLE TRADE_TYPE 
FIELDS TERMINATED BY '|'
(  TT_ID ,          
 TT_NAME ,
 TT_IS_SELL ,
 TT_IS_MRKT        
)
