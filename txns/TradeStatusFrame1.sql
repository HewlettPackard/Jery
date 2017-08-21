CREATE OR REPLACE PACKAGE BODY TradeStatusFrame1_Pkg AS 
FUNCTION TradeStatusFrame1(acct_id IN NUMBER)
RETURN TradeStatusFrame1_tab
AS
	-- output parameters
	cust_l_name VARCHAR2(30);
	cust_f_name VARCHAR2(30);
	broker_name VARCHAR2(100);
	list_len INTEGER;

	-- variables
	TradeStatusFrame1_tbl TradeStatusFrame1_tab := TradeStatusFrame1_tab();
	rec TradeStatusFrame1_record;
BEGIN
    list_len := 0;
	cust_l_name :='';
	cust_f_name :='';
	broker_name :='';
	
	
	-- Only want 50 rows, the 50 most recent trades for this customer account
	SELECT	C_L_NAME, 		C_F_NAME,		B_NAME 	INTO 	cust_l_name,		cust_f_name,		broker_name
	FROM	CUSTOMER_ACCOUNT,		CUSTOMER,		BROKER
	WHERE	CA_ID = acct_id AND
		C_ID = CA_C_ID AND
		B_ID = CA_B_ID;

	FOR rec IN
		(SELECT	cust_l_name,
			cust_f_name,
			broker_name,
			T_CHRG,
			T_EXEC_NAME,
			EX_NAME,
			S_NAME,
			ST_NAME,
			T_S_SYMB,
			extract(year from T_DTS),
			extract(month from T_DTS) ,
			extract(day from T_DTS) ,
			extract(hour from T_DTS) ,
			extract(minute from T_DTS) ,
			extract(second from T_DTS) ,
			T_ID,
			T_QTY,
			TT_NAME 
		FROM	TRADE,
			STATUS_TYPE,
			TRADE_TYPE,
			SECURITY,
			EXCHANGE
		WHERE	T_CA_ID = acct_id AND
			ST_ID = T_ST_ID AND
			TT_ID = T_TT_ID AND
			S_SYMB = T_S_SYMB AND
			EX_ID = S_EX_ID and rownum  <= 50 
		ORDER BY T_DTS desc)
	LOOP
				list_len := list_len + 1 ;
				TradeStatusFrame1_tbl.extend ;
				TradeStatusFrame1_tbl(list_len) :=rec;
				
	END LOOP;
	
	RETURN TradeStatusFrame1_tbl;
	END TradeStatusFrame1;
END TradeStatusFrame1_Pkg;
