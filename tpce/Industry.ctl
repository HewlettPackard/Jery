LOAD DATA INFILE '/tmp/jery/tables/Industry.txt'
TRUNCATE
INTO TABLE INDUSTRY 
FIELDS TERMINATED BY '|'
(  IN_ID ,          
 IN_NAME ,
 IN_SC_ID        
)
