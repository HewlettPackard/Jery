LOAD DATA INFILE '/tmp/jery/tables/CommissionRate.txt'
TRUNCATE
INTO TABLE COMMISSION_RATE
FIELDS TERMINATED BY '|'
(  CR_C_TIER ,          
 CR_TT_ID ,
 CR_EX_ID ,
 CR_FROM_QTY ,
 CR_TO_QTY ,
 CR_RATE        
)
