LOAD DATA INFILE '/tpce/Security.txt'
TRUNCATE
INTO TABLE SECURITY 
FIELDS TERMINATED BY '|'
(  S_SYMB ,          
 S_ISSUE ,
 S_ST_ID ,
 S_NAME ,
 S_EX_ID ,        
 S_CO_ID ,        
 S_NUM_OUT ,        
 S_START_DATE DATE "YYYY-MM-DD" ,        
 S_EXCH_DATE DATE "YYYY-MM-DD" ,        
 S_PE ,        
 S_52WK_HIGH ,        
 S_52WK_HIGH_DATE DATE "YYYY-MM-DD" ,        
 S_52WK_LOW ,        
 S_52WK_LOW_DATE DATE "YYYY-MM-DD" ,        
 S_DIVIDEND ,        
 S_YIELD         
)
