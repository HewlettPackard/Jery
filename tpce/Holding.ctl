LOAD DATA INFILE '/tpce/Holding.txt'
TRUNCATE
INTO TABLE HOLDING 
FIELDS TERMINATED BY '|'
(  H_T_ID ,          
 H_CA_ID ,
 H_S_SYMB ,
 H_DTS TIMESTAMP "YYYY-MM-DD HH24:MI:SS.FF9"  ,
 H_PRICE ,
 H_QTY        
)
