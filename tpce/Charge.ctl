LOAD DATA INFILE '/tmp/jery/tables/Charge.txt'
TRUNCATE
INTO TABLE CHARGE 
FIELDS TERMINATED BY '|'
(  CH_TT_ID ,          
 CH_C_TIER ,
 CH_CHRG        
)
