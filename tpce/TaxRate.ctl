LOAD DATA INFILE '/tmp/jery/tables/TaxRate.txt'
TRUNCATE
INTO TABLE TAXRATE 
FIELDS TERMINATED BY '|'
(  TX_ID ,          
 TX_NAME ,
 TX_RATE        
)
