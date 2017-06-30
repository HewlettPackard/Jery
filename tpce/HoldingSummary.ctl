LOAD DATA INFILE '/tmp/jery/tables/HoldingSummary.txt'
TRUNCATE
INTO TABLE HOLDING_SUMMARY 
FIELDS TERMINATED BY '|'
(  HS_CA_ID ,          
 HS_S_SYMB ,
 HS_QTY        
)
