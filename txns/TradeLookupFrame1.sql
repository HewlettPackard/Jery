CREATE OR REPLACE PACKAGE BODY TradeLookupFrame1_Pkg as
FUNCTION TradeLookupFrame1(max_trades IN NUMBER, trade_id IN ARINT15 )
RETURN TradeLookupFrame1_tab
AS
	-- output parameters
   bid_price  NUMBER(8,2);
   exec_name  varchar2(64);
   is_cash  NUMBER(5,0);
   is_market  NUMBER(5,0);
   trade_price  NUMBER(8,2);
   settlement_amount  NUMBER(10,2);
   settlement_cash_due_date  TIMESTAMP(6);
   settlement_cash_type  varchar2(40);
   cash_transaction_amount  NUMBER(10,2);
   cash_transaction_dts  TIMESTAMP(6);
   cash_transaction_name  varchar2(100);
   trade_history_dts  ARTIMESTAMP;
   trade_history_status_id  ARCHAR_4;

	-- variables
	i		integer;
	j		integer;
	num_found	integer;
	rec1		TradeLookupFrame1_record1;
	rec2		TradeLookupFrame1_record2;
	TradeLookupFrame1_tbl TradeLookupFrame1_tab := TradeLookupFrame1_tab();
BEGIN
	num_found := max_trades;

	i := 1;
	WHILE i <= max_trades 
	LOOP

		-- Get trade information
		-- Should only return one row for each trade

		SELECT	T_BID_PRICE,
			T_EXEC_NAME,
			T_IS_CASH,
			TT_IS_MRKT,
			T_TRADE_PRICE
		INTO	bid_price,
			exec_name,
			is_cash,
			is_market,
			trade_price
		FROM	TRADE,
			TRADE_TYPE
		WHERE	T_ID = trade_id(i) AND
			T_TT_ID = TT_ID;
		
		-- Get settlement information
		-- Should only return one row for each trade

		SELECT	SE_AMT,
			SE_CASH_DUE_DATE,
			SE_CASH_TYPE
		INTO	settlement_amount,
			settlement_cash_due_date,
			settlement_cash_type
		FROM	SETTLEMENT
		WHERE	SE_T_ID = trade_id(i) and rownum <=1 ;
			
		-- get cash information if this is a cash transaction
		-- Should only return one row for each trade that was a cash transaction

		IF is_cash = 1
		THEN
			SELECT	CT_AMT,
				CT_DTS,
				CT_NAME
			INTO	cash_transaction_amount,
				cash_transaction_dts,
				cash_transaction_name
			FROM	CASH_TRANSACTION
			WHERE	CT_T_ID = trade_id(i) and rownum <=1;
		END IF;

		-- read trade_history for the trades
		-- Should return 2 to 3 rows per trade

		j := 1;
		FOR rec1 IN 
		    (SELECT TH_DTS, TH_ST_ID 
			FROM TRADE_HISTORY
			WHERE TH_T_ID = trade_id(i) ORDER BY TH_DTS )
		LOOP
			trade_history_dts(j) := rec1.TH_DTS;
			trade_history_status_id(j) := rec1.TH_ST_ID;
			j := j + 1;
		END LOOP;

		FOR rec2 IN 
				(select bid_price,
					   exec_name,
					   is_cash,
					   is_market,
					   trade_price,
				       settlement_amount,
				       extract(year from settlement_cash_due_date) as SWC_C1,
				       extract(month from settlement_cash_due_date) as SWC_C2,
				       extract(day from settlement_cash_due_date) as SWC_C3,
				       extract(hour from CAST(settlement_cash_due_date as TIMESTAMP)) as SWC_C4,
				       extract(minute from CAST(settlement_cash_due_date as TIMESTAMP))  as SWC_C5,
				       extract(second from CAST(settlement_cash_due_date as TIMESTAMP))  as SWC_C6,
				       settlement_cash_type,
					   cash_transaction_amount,
				       extract(year from cash_transaction_dts)  as SWC_C7,
				       extract(month from cash_transaction_dts)  as SWC_C8,
				       extract(day from cash_transaction_dts)  as SWC_C9,
				       extract(hour from cash_transaction_dts)  as SWC_C10,
				       extract(minute from cash_transaction_dts)  as SWC_C11,
				       extract(second from cash_transaction_dts) as SWC_C12,
				       cash_transaction_name,
				       extract(year from trade_history_dts(1))  as SWC_C13,
				       extract(month from trade_history_dts(1)) as SWC_C14, 
				       extract(day from trade_history_dts(1)) as SWC_C15,
				       extract(hour from trade_history_dts(1)) as SWC_C16, 
				       extract(minute from trade_history_dts(1)) as SWC_C17,
				       extract(second from trade_history_dts(1)) as SWC_C18,
				       trade_history_status_id(1),
				       extract(year from trade_history_dts(2)) as SWC_C20,
				       extract(month from trade_history_dts(2)) as SWC_C21,
				       extract(day from trade_history_dts(2)) as SWC_C22,
				       extract(hour from trade_history_dts(2)) as SWC_C23,
				       extract(minute from trade_history_dts(2)) as SWC_C24,
				       extract(second from trade_history_dts(2)) as SWC_C25,
				       trade_history_status_id(2),
				       extract(year from trade_history_dts(3)) as SWC_C27,
				       extract(month from trade_history_dts(3)) as SWC_C28,
				       extract(day from trade_history_dts(3)) as SWC_C29,
				       extract(hour from trade_history_dts(3)) as SWC_C30,
				       extract(minute from trade_history_dts(3)) as SWC_C31,
				       extract(second from trade_history_dts(3)) as SWC_C32,
				       trade_history_status_id(3) from dual
					   )
		LOOP
			TradeLookupFrame1_tbl.extend;
			TradeLookupFrame1_tbl(i) := rec2;
		END LOOP;

		i := i + 1;
	END LOOP;
	RETURN TradeLookupFrame1_tbl;
END;


/*
 * Frame 2
 * returns information for the first N (max_trades) trades executed for the
 * specified customer account at or after the specified time.
 */

FUNCTION TradeLookupFrame2(	acct_id	IN NUMBER,	max_trades	IN integer,	trade_dts	IN timestamp)
RETURN TradeLookupFrame1_tab1
AS
    
	-- output parameters
   settlement_amount  NUMBER(10,2);
   settlement_cash_due_date  TIMESTAMP(6);
   settlement_cash_type  varchar2(40);
   cash_transaction_amount  NUMBER(10,2);
   cash_transaction_dts  TIMESTAMP(6);
   cash_transaction_name  varchar2(100);
   trade_history_dts  ARTIMESTAMP;
   trade_history_status_id  ARCHAR_4;

	-- variables
	i		integer;
	j		integer;
	num_found	integer;
    rec1		TradeLookupFrame1_record1;
	rec2		TradeLookupFrame1_record3;
	rec3		TradeLookupFrame1_record4;
	TradeLookupFrame1_tbl TradeLookupFrame1_tab1 := TradeLookupFrame1_tab1();
BEGIN
	-- Get trade information
	-- Should return between 0 and max_trades rows

	i := 0;
	FOR rec3 IN (SELECT T_BID_PRICE,
			T_EXEC_NAME,
			T_IS_CASH,
			T_ID,
			T_TRADE_PRICE
		FROM	TRADE
		WHERE	T_CA_ID = acct_id AND
			T_DTS >= trade_dts and rownum <= max_trades
		ORDER BY T_DTS asc )
	LOOP

		-- Get settlement information
		-- Should return only one row for each trade

		SELECT	SE_AMT,
			SE_CASH_DUE_DATE,
			SE_CASH_TYPE
		INTO	settlement_amount,
			settlement_cash_due_date,
			settlement_cash_type
		FROM	SETTLEMENT
		WHERE	SE_T_ID = rec3.T_ID;

		-- get cash information if this is a cash transaction
		-- Should return only one row for each trade that was a cash transaction

		IF rec3.T_IS_CASH =1 
		THEN
			SELECT	CT_AMT,
 				CT_DTS,
				CT_NAME
			INTO	cash_transaction_amount,
				cash_transaction_dts,
				cash_transaction_name
			FROM	CASH_TRANSACTION
			WHERE	CT_T_ID = rec3.T_ID;
		END IF;

		-- read trade_history for the trades
		-- Should return 2 to 3 rows per trade

		j := 1;
		FOR rec1 IN (SELECT TH_DTS, TH_ST_ID 
			FROM TRADE_HISTORY
			WHERE TH_T_ID = rec3.T_ID ORDER BY TH_DTS)
		LOOP
			trade_history_dts(j) := rec1.TH_DTS;
			trade_history_status_id(j) := rec1.TH_ST_ID;
			j := j + 1;
		END LOOP;

		FOR rec2 IN
				(SELECT rec3.T_BID_PRICE , 
					   rec3.T_EXEC_NAME,
					   rec3.T_IS_CASH,
				       rec3.T_TRADE_PRICE,
					   rec3.T_ID ,
				       settlement_amount,
				       extract(year from settlement_cash_due_date) as SWC_C1,
				       extract(month from settlement_cash_due_date) as SWC_C2,
				       extract(day from settlement_cash_due_date) as SWC_C3,
				       extract(hour from CAST(settlement_cash_due_date as TIMESTAMP)) as SWC_C4,
				       extract(minute from CAST(settlement_cash_due_date as TIMESTAMP))  as SWC_C5,
				       extract(second from CAST(settlement_cash_due_date as TIMESTAMP))  as SWC_C6,
				       settlement_cash_type,
					   cash_transaction_amount,
				       extract(year from cash_transaction_dts)  as SWC_C7,
				       extract(month from cash_transaction_dts)  as SWC_C8,
				       extract(day from cash_transaction_dts)  as SWC_C9,
				       extract(hour from cash_transaction_dts)  as SWC_C10,
				       extract(minute from cash_transaction_dts)  as SWC_C11,
				       extract(second from cash_transaction_dts) as SWC_C12,
				       cash_transaction_name, 
				       extract(year from trade_history_dts(1))  as SWC_C13,
				       extract(month from trade_history_dts(1)) as SWC_C14, 
				       extract(day from trade_history_dts(1)) as SWC_C15,
				       extract(hour from trade_history_dts(1)) as SWC_C16, 
				       extract(minute from trade_history_dts(1)) as SWC_C17,
				       extract(second from trade_history_dts(1)) as SWC_C18,
				       trade_history_status_id(1),
				       extract(year from trade_history_dts(2)) as SWC_C20,
				       extract(month from trade_history_dts(2)) as SWC_C21,
				       extract(day from trade_history_dts(2)) as SWC_C22,
				       extract(hour from trade_history_dts(2)) as SWC_C23,
				       extract(minute from trade_history_dts(2)) as SWC_C24,
				       extract(second from trade_history_dts(2)) as SWC_C25,
				       trade_history_status_id(2),
				       extract(year from trade_history_dts(3)) as SWC_C27,
				       extract(month from trade_history_dts(3)) as SWC_C28,
				       extract(day from trade_history_dts(3)) as SWC_C29,
				       extract(hour from trade_history_dts(3)) as SWC_C30,
				       extract(minute from trade_history_dts(3)) as SWC_C31,
				       extract(second from trade_history_dts(3)) as SWC_C32,
				       trade_history_status_id(3) from dual
					   )
		LOOP
			TradeLookupFrame1_tbl.extend;
			TradeLookupFrame1_tbl(i) := rec2;
		END LOOP;

		i := i + 1;
	END LOOP;
RETURN TradeLookupFrame1_tbl;
END;



/*
 * Frame 3
 * returns up to N (max_trades) trades for a given security on or after a
 * specified point in time.
 */
FUNCTION TradeLookupFrame3( max_acct_id IN NUMBER,
                            max_trades IN INTEGER,
							TRADE_DTS in TIMESTAMP,
							SYMBOL IN VARCHAR2)
RETURN TradeLookupFrame1_tab2
AS
	-- output parameters
   settlement_amount  NUMBER(10,2);
   settlement_cash_due_date  TIMESTAMP(6);
   settlement_cash_type  varchar2(40);
   cash_transaction_amount  NUMBER(10,2);
   cash_transaction_dts  TIMESTAMP(6);
   cash_transaction_name  varchar2(100);
   trade_history_dts  ARTIMESTAMP;
   trade_history_status_id  ARCHAR_4;

	-- variables
	i		integer;
	j		integer;
	
	rec1		TradeLookupFrame1_record6;
	rec3		TradeLookupFrame1_record7;
	rec2 		TradeLookupFrame1_record1;
	TradeLookupFrame1_tbl TradeLookupFrame1_tab2 := TradeLookupFrame1_tab2();
	
	

BEGIN
	-- Should return between 0 and max_trades rows.

	i := 0;
	FOR rec1 IN 
			(SELECT T_CA_ID,
			T_EXEC_NAME,
			T_IS_CASH,
			T_ID,
			T_TRADE_PRICE,
			T_QTY,
			T_DTS,
			T_TT_ID
		FROM	TRADE
		WHERE	T_S_SYMB = symbol AND
			T_DTS >= trade_dts AND
			T_CA_ID <= max_acct_id and rownum <= max_trades
		ORDER BY T_DTS asc)
	
	LOOP

		-- Get extra information for each trade in the trade list.
		-- Get settlement information
		-- Should return only one row for each trade

		SELECT	SE_AMT,
			SE_CASH_DUE_DATE,
			SE_CASH_TYPE
		INTO	settlement_amount,
			settlement_cash_due_date,
			settlement_cash_type
		FROM	SETTLEMENT
		WHERE	SE_T_ID = rec1.T_ID;

		-- get cash information if this is a cash transaction
		-- Should return only one row for each trade that was a cash transaction

		IF rec1.T_IS_CASH =1 
		THEN
			SELECT	CT_AMT,
 				CT_DTS,
				CT_NAME
			INTO	cash_transaction_amount,
				cash_transaction_dts,
				cash_transaction_name
			FROM	CASH_TRANSACTION
			WHERE	CT_T_ID = rec1.T_ID;
		END IF;

		-- read trade_history for the trades
		-- Should return 2 to 3 rows per trade

		j := 1;
		FOR rec2 IN 
		(SELECT TH_DTS, TH_ST_ID 
			FROM TRADE_HISTORY
			WHERE TH_T_ID = rec1.T_ID ORDER BY TH_DTS)
		LOOP
			trade_history_dts(j) := rec2.TH_DTS;
			trade_history_status_id(j) := rec2.TH_ST_ID;
			j := j + 1;
		END LOOP;

		FOR rec3 IN
				(SELECT rec1.T_CA_ID, 
					   cash_transaction_amount,
				       extract(year from cash_transaction_dts)  as SWC_C7,
				       extract(month from cash_transaction_dts)  as SWC_C8,
				       extract(day from cash_transaction_dts)  as SWC_C9,
				       extract(hour from cash_transaction_dts)  as SWC_C10,
				       extract(minute from cash_transaction_dts)  as SWC_C11,
				       extract(second from cash_transaction_dts) as SWC_C12,
				       cash_transaction_name,
					   rec1.T_EXEC_NAME,
				       rec1.T_IS_CASH,
					   rec1.T_TRADE_PRICE,
					   rec1.T_QTY,
				       settlement_amount, 
				       extract(year from settlement_cash_due_date) as SWC_C1,
				       extract(month from settlement_cash_due_date) as SWC_C2,
				       extract(day from settlement_cash_due_date) as SWC_C3,
				       extract(hour from CAST(settlement_cash_due_date as TIMESTAMP)) as SWC_C4,
				       extract(minute from CAST(settlement_cash_due_date as TIMESTAMP))  as SWC_C5,
				       extract(second from CAST(settlement_cash_due_date as TIMESTAMP))  as SWC_C6,
				       settlement_cash_type,
					   extract(year from rec1.T_DTS) as SWC_C33,
				       extract(month from rec1.T_DTS) as SWC_C34,
				       extract(day from rec1.T_DTS) as SWC_C35, 
					   extract(hour from rec1.T_DTS) as SWC_C36,
				       extract(minute from rec1.T_DTS) as SWC_C37, 
				       extract(second from rec1.T_DTS) as SWC_C38,
				       extract(year from trade_history_dts(1))  as SWC_C13,
				       extract(month from trade_history_dts(1)) as SWC_C14, 
				       extract(day from trade_history_dts(1)) as SWC_C15,
				       extract(hour from trade_history_dts(1)) as SWC_C16, 
				       extract(minute from trade_history_dts(1)) as SWC_C17,
				       extract(second from trade_history_dts(1)) as SWC_C18,
				       trade_history_status_id(1),
				       extract(year from trade_history_dts(2)) as SWC_C20,
				       extract(month from trade_history_dts(2)) as SWC_C21,
				       extract(day from trade_history_dts(2)) as SWC_C22,
				       extract(hour from trade_history_dts(2)) as SWC_C23,
				       extract(minute from trade_history_dts(2)) as SWC_C24,
				       extract(second from trade_history_dts(2)) as SWC_C25,
				       trade_history_status_id(2),
				       extract(year from trade_history_dts(3)) as SWC_C27,
				       extract(month from trade_history_dts(3)) as SWC_C28,
				       extract(day from trade_history_dts(3)) as SWC_C29,
				       extract(hour from trade_history_dts(3)) as SWC_C30,
				       extract(minute from trade_history_dts(3)) as SWC_C31,
				       extract(second from trade_history_dts(3)) as SWC_C32,
					   trade_history_status_id(3),
					   rec1.T_ID,
					   rec1.T_TT_ID from dual)
		LOOP
			TradeLookupFrame1_tbl.extend;
			TradeLookupFrame1_tbl(i) := rec3;
		END LOOP;

		i := i + 1;
	END LOOP;
	RETURN TradeLookupFrame1_tbl;
END;



/*
 * Frame 4
 * identifies the first trade for the specified customer account on or after
 * the specified time.
 */

FUNCTION TradeLookupFrame4(acct_id	IN NUMBER,trade_dts	 IN timestamp)
RETURN TradeLookupFrame1_tab3
AS
	-- Local Frame variables
	rec1		TradeLookupFrame1_record5;
	i integer;
	-- output parameters	
	trade_id	NUMBER(15);
	TradeLookupFrame1_tbl TradeLookupFrame1_tab3 := TradeLookupFrame1_tab3();
BEGIN
    i := 1;
	SELECT	T_ID
	INTO	trade_id
	FROM	TRADE
	WHERE	T_CA_ID = acct_id AND
		T_DTS >= trade_dts and rownum <=1
	ORDER BY T_DTS asc;
	

	-- The trade_id is used in the subquery to find the original trade_id
	-- (HH_H_T_ID), which then is used to list all the entries.
	-- Should return 0 to 20 rows.
	
	FOR rec1 IN 
		(SELECT HH_H_T_ID,
			HH_T_ID,
			HH_BEFORE_QTY,
			HH_AFTER_QTY,
			trade_id
			FROM	HOLDING_HISTORY
			WHERE	HH_H_T_ID in
				(SELECT	HH_H_T_ID
				FROM	HOLDING_HISTORY
				WHERE	HH_T_ID = trade_id)
		and rownum <=20)
	LOOP
		TradeLookupFrame1_tbl.extend;
		TradeLookupFrame1_tbl(i) := rec1;
		i := i + 1;
	END LOOP;
	RETURN TradeLookupFrame1_tbl;
END;
END TradeLookupFrame1_Pkg;
