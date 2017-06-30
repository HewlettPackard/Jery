LOAD DATA INFILE '/tmp/jery/tables/TradeRequest.txt'
TRUNCATE
INTO TABLE TRADE_REQUEST 
FIELDS TERMINATED BY '|'
(  TR_T_ID ,          
 TR_TT_ID ,
 TR_S_SYMB ,
 TR_QTY ,
 TR_BID_PRICE ,
 TR_B_ID        
)
