create or replace PACKAGE  CustomerPosition_pkg AS
TYPE ID_ARRAY is varray(50) of NUMBER(11);
TYPE TOT_ARRAY IS varray(50) OF NUMBER(14,2);
TYPE SUM_ARRAY is varray(50) of NUMBER(38, 2);
TYPE C_NAME_ARRAY is varray(50) of varchar(15);
TYPE C_NUM_ARRAY is varray(50) of NUMBER(15);
TYPE C_TMPSTMP_ARRAY is varray(50) of TIMESTAMP;
TYPE CustomerPositionFrame1_record IS RECORD (
				CA_ID NUMBER(11),
			    CA_BAL NUMBER(12,2),
			    soma NUMBER(38,2)
                                );
TYPE CustomerPositionFrame1_tab IS TABLE OF CustomerPositionFrame1_record;

TYPE CustomerPositionFrame2_record IS RECORD (
               T_ID NUMBER(15),
			    T_S_SYMB VARCHAR2(15),
			    T_QTY NUMBER(6),
		    ST_NAME VARCHAR2(10),
		    TH_DTS TIMESTAMP(6)
				);
				
TYPE CustomerPositionFrame2_tab IS TABLE OF CustomerPositionFrame2_record;

FUNCTION CustomerPositionFrame1 (
		cust_id IN OUT NUMBER,
		tax_id IN VARCHAR2,
		acct_id OUT ID_ARRAY,
		acct_len OUT INTEGER,
		asset_total OUT TOT_ARRAY,
		c_ad_id OUT NUMBER, 
		c_area_1 OUT VARCHAR,
		c_area_2 OUT VARCHAR,
		c_area_3 OUT VARCHAR,
		c_ctry_1 OUT VARCHAR, 
		c_ctry_2 OUT VARCHAR,
		c_ctry_3 OUT VARCHAR,
		c_dob OUT DATE,
		c_email_1 OUT VARCHAR2,
		c_email_2 OUT VARCHAR2,
		c_ext_1 OUT VARCHAR,
		c_ext_2 OUT VARCHAR,
		c_ext_3 OUT VARCHAR,
		c_f_name OUT VARCHAR2,
		c_gndr OUT VARCHAR,
		c_l_name OUT VARCHAR2,
		c_local_1 OUT VARCHAR,
		c_local_2 OUT VARCHAR,
		c_local_3 OUT VARCHAR,
		c_m_name OUT VARCHAR,
		c_st_id OUT VARCHAR,
		c_tier OUT NUMBER,
		cash_bal OUT TOT_ARRAY,
		status OUT INTEGER
		)		
RETURN CustomerPositionFrame1_tab; 

FUNCTION CustomerPositionFrame2(
		acct_id IN NUMBER,
		hist_dts OUT C_TMPSTMP_ARRAY,
		hist_len OUT INTEGER,
		qty OUT C_NUM_ARRAY,
		status OUT INTEGER,
		symbol OUT C_NAME_ARRAY,
		trade_id OUT C_NUM_ARRAY,
		trade_status OUT C_NAME_ARRAY)
RETURN CustomerPositionFrame2_tab;	

END CustomerPosition_pkg ;
/
