LOAD DATA INFILE '/tmp/jery/tables/ZipCode.txt'
TRUNCATE
INTO TABLE ZIP_CODE 
FIELDS TERMINATED BY '|'
(  ZC_CODE ,          
 ZC_TOWN ,
 ZC_DIV        
)
