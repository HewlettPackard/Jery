create or replace PACKAGE BODY CustomerPosition_pkg  AS
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
		status OUT INTEGER)
RETURN CustomerPositionFrame1_tab
AS
CustomerPositionFrame1_tbl  CustomerPositionFrame1_tab := CustomerPositionFrame1_tab();
rec CustomerPositionFrame1_record;

BEGIN
	acct_id :=	ID_ARRAY();
asset_total :=	TOT_ARRAY();
cash_bal  :=	TOT_ARRAY();
	IF cust_id = 0 THEN
		SELECT	C_ID
		INTO	cust_id
		FROM	CUSTOMER
		WHERE	C_TAX_ID = tax_id;
	END IF;

	SELECT	C_ST_ID,
	        C_L_NAME,
	        C_F_NAME,
	        C_M_NAME,
	        C_GNDR,
	        C_TIER,
	        C_DOB,
	        C_AD_ID,
	        C_CTRY_1,
	        C_AREA_1,
	        C_LOCAL_1,
	        C_EXT_1,
	        C_CTRY_2,
	        C_AREA_2,
	        C_LOCAL_2,
	        C_EXT_2,
	        C_CTRY_3,
	        C_AREA_3,
	        C_LOCAL_3,
	        C_EXT_3,
	        C_EMAIL_1,
	        C_EMAIL_2
	INTO	C_ST_ID,
	        C_L_NAME,
	        C_F_NAME,
	        C_M_NAME,
	        C_GNDR,
	        C_TIER,
	        C_DOB,
	        C_AD_ID,
	        C_CTRY_1,
	        C_AREA_1,
	        C_LOCAL_1,
	        C_EXT_1,
	        C_CTRY_2,
	        C_AREA_2,
	        C_LOCAL_2,
	        C_EXT_2,
	        C_CTRY_3,
	        C_AREA_3,
	        C_LOCAL_3,
	        C_EXT_3,
	        C_EMAIL_1,
	        C_EMAIL_2
	FROM	CUSTOMER
	WHERE	c_id = cust_id;

	-- Should return 1 to max_acct_len.
	acct_len := 0;
	FOR rec IN
			(SELECT CA_ID,
			       CA_BAL,
			       sum(HS_QTY * LT_PRICE) as soma
			FROM CUSTOMER_ACCOUNT left outer join
			     HOLDING_SUMMARY on HS_CA_ID = CA_ID,
			     LAST_TRADE
			WHERE CA_C_ID = cust_id
			  AND LT_S_SYMB = HS_S_SYMB and Rownum <= 10
			GROUP BY CA_ID, CA_BAL
			ORDER BY 3 asc)
			
	LOOP
	    CustomerPositionFrame1_tbl.extend;
		acct_len := acct_len + 1;
		dbms_output.put_line('acct_len here : ' || acct_len);
		acct_id.extend;
		cash_bal.extend;
		acct_id(acct_len) := rec.CA_ID;
		cash_bal(acct_len) := rec.CA_BAL;
          
		asset_total.extend;
		IF rec.soma is null THEN
			asset_total(acct_len) := 0.00;
		ELSE
			asset_total(acct_len) := rec.soma;
		END IF;
		
		CustomerPositionFrame1_tbl(acct_len) := rec;
	END LOOP;

	status := 0;
	dbms_output.put_line('status: ' || status);
	dbms_output.put_line('acct_len: ' || acct_len);
	
	RETURN CustomerPositionFrame1_tbl;

END CustomerPositionFrame1;

FUNCTION CustomerPositionFrame2(
		acct_id IN NUMBER,
		hist_dts OUT C_TMPSTMP_ARRAY,
		hist_len OUT INTEGER,
		qty OUT C_NUM_ARRAY,
		status OUT INTEGER,
		symbol OUT C_NAME_ARRAY,
		trade_id OUT C_NUM_ARRAY,
		trade_status OUT C_NAME_ARRAY)
RETURN CustomerPositionFrame2_tab
AS
CustomerPositionFrame2_tbl  CustomerPositionFrame2_tab := CustomerPositionFrame2_tab();
rec CustomerPositionFrame2_record;

BEGIN
	hist_dts :=	C_TMPSTMP_ARRAY();
	qty  :=	C_NUM_ARRAY();
	symbol  :=	C_NAME_ARRAY();
	trade_id :=  C_NUM_ARRAY();
	trade_status := C_NAME_ARRAY();
	hist_len := 0;

	FOR rec IN
			(SELECT T_ID,
			       T_S_SYMB,
			       T_QTY,
			       ST_NAME,
			       TH_DTS
			FROM 
				(SELECT T_ID as ID FROM TRADE WHERE T_CA_ID = acct_id  and rownum <=10 ORDER BY T_DTS DESC) T   ,
			     TRADE,
			     TRADE_HISTORY,
			     STATUS_TYPE
			WHERE 
			  T_ID = ID
			  AND TH_T_ID = T_ID
			  AND ST_ID = TH_ST_ID and rownum <=30
			ORDER BY TH_DTS desc)
			
	LOOP
	    CustomerPositionFrame2_tbl.extend;
		hist_len := hist_len + 1;
		trade_id.extend;
		trade_id(hist_len) := rec.t_id;
		symbol.extend;
		symbol(hist_len) := rec.t_s_symb;
		qty.extend;
		qty(hist_len) := rec.t_qty;
		trade_status.extend;
		trade_status(hist_len) := rec.st_name;
		hist_dts.extend;
		hist_dts(hist_len) := rec.th_dts;
		CustomerPositionFrame2_tbl(hist_len) :=rec;
	END LOOP;

	status := 0;

	RETURN CustomerPositionFrame2_tbl;
    END  CustomerPositionFrame2;
END CustomerPosition_pkg;
/

