LOAD DATA INFILE '/tmp/jery/tables/HoldingHistory.txt'
TRUNCATE
INTO TABLE HOLDING_HISTORY 
FIELDS TERMINATED BY '|'
(  HH_H_T_ID ,          
 HH_T_ID ,
 HH_BEFORE_QTY ,
 HH_AFTER_QTY        
)
