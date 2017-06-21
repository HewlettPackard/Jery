LOAD DATA INFILE '/tpce/CashTransaction.txt'
TRUNCATE
INTO TABLE cash_transaction 
FIELDS TERMINATED BY '|'
(  CT_T_ID ,          
 CT_DTS TIMESTAMP "YYYY-MM-DD HH24:MI:SS.FF9" ,
 CT_AMT ,
 CT_NAME        
)
