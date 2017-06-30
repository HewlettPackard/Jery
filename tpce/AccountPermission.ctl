LOAD DATA INFILE '/tmp/jery/tables/AccountPermission.txt'
TRUNCATE
INTO TABLE ACCOUNT_PERMISSION 
FIELDS TERMINATED BY '|'
(  AP_CA_ID ,          
 AP_ACL ,
 AP_TAX_ID ,
 AP_L_NAME ,
 AP_F_NAME        
)
