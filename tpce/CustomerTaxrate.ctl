LOAD DATA INFILE '/tmp/jery/tables/CustomerTaxrate.txt'
TRUNCATE
INTO TABLE CUSTOMER_TAXRATE 
FIELDS TERMINATED BY '|'
(  CX_TX_ID ,          
 CX_C_ID        
)
