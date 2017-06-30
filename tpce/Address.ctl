LOAD DATA INFILE '/tmp/jery/tables/Address.txt'
TRUNCATE
INTO TABLE ADDRESS 
FIELDS TERMINATED BY '|'
(  AD_ID ,          
 AD_LINE1 ,
 AD_LINE2 ,
 AD_ZC_CODE ,
 AD_CTRY        
)
