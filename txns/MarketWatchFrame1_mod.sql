CREATE OR REPLACE PACKAGE BODY  MarketWatchFrame1_Pkg AS
FUNCTION MarketWatchFrame1 (
						acct_id		IN NUMBER,
						cust_id		IN NUMBER,
						ending_co_id IN NUMBER,
						industry_name IN VARCHAR2,
						starting_co_id 	IN NUMBER)
RETURN MarketWatchFrame1_tab
AS
	MarketWatchFrame1_tbl MarketWatchFrame1_tab := MarketWatchFrame1_tab() ;
	rec MarketWatchFrame1_record;
	old_mkt_cap	double precision;
	new_mkt_cap	double precision;
	pct_change	double precision;
	symbol		char(15);
	sec_num_out	NUMBER(12);
	old_price	NUMBER(10,2);
	new_price	NUMBER(10,2);
	
	STOCK_LIST GenCurTyp;

	-- cursor
	--TYPE STOCK_LIST  IS REF CURSOR RETURN WATCH_ITEM%ROWTYPE; 
	--TYPE EmpCurTyp IS REF CURSOR RETURN emp%ROWTYPE;
	--stock_list	refcursor;
BEGIN
	symbol :='';
	IF cust_id != 0 
	THEN
		OPEN	stock_list 
		FOR
		SELECT	distinct WI_S_SYMB
		FROM	WATCH_ITEM
		WHERE	WI_WL_ID in (SELECT WL_ID
					FROM WATCH_LIST
					WHERE WL_C_ID = cust_id);
	ELSIF industry_name != '' 
	THEN
		OPEN stock_list FOR
		SELECT	S_SYMB
		FROM	INDUSTRY,
			COMPANY,
			SECURITY
		WHERE	IN_NAME = industry_name AND
			CO_IN_ID = IN_ID AND
			CO_ID BETWEEN starting_co_id AND ending_co_id AND
			S_CO_ID = CO_ID;
	ELSIF acct_id != 0 
	THEN
		OPEN stock_list FOR
		SELECT	HS_S_SYMB
		FROM	HOLDING_SUMMARY
		WHERE	HS_CA_ID = acct_id;
	ELSE
			MarketWatchFrame1_tbl.extend;
	        rec.status  := '-1::smallint';
            rec.status_desc := '0.0  -- status fail';
            rec.pct_change := pct_change;
			MarketWatchFrame1_tbl(1) := rec;
		
		RETURN MarketWatchFrame1_tbl;
	END IF;

	old_mkt_cap := 0.0;
	new_mkt_cap := 0.0;
	pct_change := 0.0;

	 
	FETCH	stock_list
	INTO	symbol;

	DBMS_OUTPUT.PUT_LINE('symbol  ==  '  || symbol);
	
	IF stock_list%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('SQL DATA NOT FOUND');
			MarketWatchFrame1_tbl.extend;
	        rec.status  := '-1::smallint';
            rec.status_desc := '0.0  -- status fail';
            rec.pct_change := pct_change;
			MarketWatchFrame1_tbl(1) := rec;
			RETURN MarketWatchFrame1_tbl;
	END IF;

	WHILE stock_list%FOUND 
	LOOP
	    BEGIN
		
		SELECT	LT_PRICE
		INTO	new_price
		FROM	LAST_TRADE
		WHERE	LT_S_SYMB = TRIM(symbol);
		
		exception when NO_DATA_FOUND then
		dbms_output.put_line ('(MarketWatchFrame1 LAST_TRADE) SQLERRM: ' || sqlerrm || '  for  symbol ' ||  symbol );
		FETCH	stock_list
		    INTO	symbol;
		CONTINUE;
	
		END;
		
		BEGIN
		
		SELECT	S_NUM_OUT
		INTO	sec_num_out
		FROM	SECURITY
		WHERE	S_SYMB = TRIM(symbol);
		
		
		exception when NO_DATA_FOUND then
		dbms_output.put_line ('(MarketWatchFrame1 SECURITY) SQLERRM: ' || sqlerrm || '  for  symbol ' ||  symbol );
		FETCH	stock_list
		    INTO	symbol;
		CONTINUE;
	
		END;
		
		-- Only want one row, the most recent closing price for this security.
		BEGIN
		
		SELECT	DM_CLOSE
		INTO	old_price
		FROM	DAILY_MARKET
		WHERE	DM_S_SYMB = trim(symbol)
		and rownum <=1
		ORDER BY DM_DATE desc;
		
		exception when NO_DATA_FOUND then
		dbms_output.put_line ('(MarketWatchFrame1 DAILY_MARKET) SQLERRM: ' || sqlerrm || '  for  symbol ' ||  symbol );
		FETCH	stock_list
		    INTO	symbol;
		CONTINUE;
	
		END;
	--	LIMIT 1;

		old_mkt_cap := old_mkt_cap + (sec_num_out * old_price);
		new_mkt_cap := new_mkt_cap + (sec_num_out * new_price);

		FETCH	stock_list
		INTO	symbol;
		
		
		

		
	END LOOP;
	
	IF old_mkt_cap != 0 THEN
		pct_change := 100 * ( ( new_mkt_cap / old_mkt_cap ) - 1);
	ELSE
		pct_change := 0;
	END IF;
	
	CLOSE stock_list;

	MarketWatchFrame1_tbl.extend;
	rec.status  := '0::smallint';
    rec.status_desc := 'pct_change	-- status ok';
    rec.pct_change := pct_change;
	MarketWatchFrame1_tbl(1) := rec;
	
	RETURN	MarketWatchFrame1_tbl;
END MarketWatchFrame1;
END MarketWatchFrame1_Pkg;
/
