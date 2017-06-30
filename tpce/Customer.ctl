LOAD DATA INFILE '/tmp/jery/tables/Customer.txt'
TRUNCATE
INTO TABLE CUSTOMER 
FIELDS TERMINATED BY '|'
(  C_ID ,          
 C_TAX_ID ,
 C_ST_ID ,
 C_L_NAME ,
 C_F_NAME ,
 C_M_NAME ,
 C_GNDR ,
 C_TIER ,
 C_DOB DATE "YYYY-MM-DD" ,
 C_AD_ID ,
 C_CTRY_1 ,
 C_AREA_1 ,
 C_LOCAL_1 ,
 C_EXT_1 ,
 C_CTRY_2 ,
 C_AREA_2 ,
 C_LOCAL_2 ,
 C_EXT_2 ,
 C_CTRY_3 ,
 C_AREA_3 ,
 C_LOCAL_3 ,
 C_EXT_3 ,
 C_EMAIL_1 ,
 C_EMAIL_2        
)
