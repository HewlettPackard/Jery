LOAD DATA INFILE '/tmp/jery/tables/Sector.txt'
TRUNCATE
INTO TABLE SECTOR 
FIELDS TERMINATED BY '|'
(  SC_ID ,          
 SC_NAME        
)
