LOAD DATA INFILE '/tmp/jery/tables/NewsXRef.txt'
TRUNCATE
INTO TABLE NEWS_XREF 
FIELDS TERMINATED BY '|'
(  NX_NI_ID ,          
 NX_CO_ID        
)
