LOAD DATA INFILE '/tmp/jery/tables/CustomerAccount.txt'
TRUNCATE
INTO TABLE CUSTOMER_ACCOUNT 
FIELDS TERMINATED BY '|'
(  CA_ID ,          
 CA_B_ID ,
 CA_C_ID ,
 CA_NAME ,
 CA_TAX_ST ,
 CA_BAL        
)
