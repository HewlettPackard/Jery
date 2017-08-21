Create or replace PACKAGE BODY TradeOrderFrame1_Pkg AS
FUNCTION TradeOrderFrame1 (acct_id IN NUMBER)
RETURN TradeOrderFrame1_tab 
AS 
	-- output parameters
	acct_name	varchar2(50);
	broker_name	VARCHAR2(100);
	cust_f_name	VARCHAR2(30);
	cust_id		NUMBER(11);
	cust_l_name	VARCHAR2(30);
	cust_tier	NUMBER(38);
	tax_id		VARCHAR2(20);
	tax_status	NUMBER(38);

	-- variables
	broker_id 	NUMBER(11);
	flag integer;
	rec	TradeOrderFrame1_record;
	TradeOrderFrame1_tbl TradeOrderFrame1_tab := TradeOrderFrame1_tab();
BEGIN
    flag :=1;
	-- Get account, customer, and broker information
	SELECT	CA_NAME,
		CA_B_ID,
		CA_C_ID,
		CA_TAX_ST
	INTO	acct_name,
		broker_id,
		cust_id,
		tax_status
	FROM	CUSTOMER_ACCOUNT
	WHERE	CA_ID = acct_id;

	SELECT	C_F_NAME,
		C_L_NAME,
		C_TIER,
		C_TAX_ID
	INTO	cust_f_name,
		cust_l_name,
		cust_tier,
		tax_id
	FROM	CUSTOMER
	WHERE	C_ID = cust_id;

	SELECT	B_NAME
	INTO	broker_name
	FROM	BROKER
	WHERE	B_ID=broker_id;

	FOR rec in (SELECT	acct_name,
		broker_name,
		cust_f_name,
		cust_id,
		cust_l_name,
		cust_tier,
		tax_id,
		tax_status from dual)
	LOOP
		TradeOrderFrame1_tbl.extend;
		TradeOrderFrame1_tbl(flag) := rec;
		flag := flag +1;
    END LOOP;	
	

	RETURN TradeOrderFrame1_tbl;
END;


/*
 * Frame 2
 * Responsible for validating the executor's permission to order trades for the
 * specified customer account
 */

FUNCTION TradeOrderFrame2(acct_id IN NUMBER,
						 exec_f_name IN varchar2,
						 exec_l_name IN varchar2,
						 exec_tax_id IN varchar2)
RETURN INTEGER
AS
	permission_cnt integer;
	bad_permission INTEGER;
BEGIN
	SELECT	COUNT(*)
	INTO	permission_cnt
	FROM	ACCOUNT_PERMISSION
	WHERE	AP_CA_ID = acct_id AND
		AP_F_NAME = exec_f_name AND
		AP_L_NAME = exec_l_name AND
		AP_TAX_ID = exec_tax_id;

	IF permission_cnt = 0 THEN
		bad_permission := 1;
	ELSE
		bad_permission := 0;
	END IF;

	RETURN	bad_permission;
END;



/*
 * Frame 3
 * Responsible for estimating the overall impact of executing the requested
 * trade
 */

FUNCTION TradeOrderFrame3(
						acct_id	IN NUMBER,
						cust_id	 IN NUMBER,
						cust_tier IN NUMBER,
						is_lifo	IN NUMBER,
						issue IN VARCHAR2,
						st_pending_id IN VARCHAR2,
						st_submitted_id	IN VARCHAR2,
						tax_status	IN NUMBER,
						trade_qty	IN NUMBER,
						trade_type_id IN VARCHAR2,
						type_is_margin	IN NUMBER,
						company_name IN varchar2,
						requested_price	IN NUMBER,
						symbol	IN VARCHAR2) 
RETURN TradeOrderFrame1_tab1
AS
	-- output parameters
	comp_name	VARCHAR2(60);
	required_price	NUMBER(8,2);	
	symb_name	VARCHAR2(15);
	buy_value	NUMBER(12,2);
	charge_amount	NUMBER(10,2);
	comm_rate	NUMBER(8,2);
	cust_assets	NUMBER(12,2);
	market_price	NUMBER(8,2);
	sec_name	VARCHAR2(70);
	sell_value	NUMBER(12,2);
	status_id	char(4);
	tax_amount	NUMBER(10,2);
	type_is_market	NUMBER(1);
	type_is_sell	NUMBER(1);

	-- variables
	comp_id		NUMBER(11);
	exch_id		char(6);
	tax_rates	NUMBER(8,2);
	acct_bal	NUMBER(12,2);
	hold_assets NUMBER(8,2);
	rec		TradeOrderFrame1_record1;
	TradeOrderFrame1_tbl TradeOrderFrame1_tab1 :=  TradeOrderFrame1_tab1();

	-- Local frame variables used when estimating impact of this trade on
	-- any current holdings of the same security.
	hold_price	NUMBER(8,2);
	hold_qty	NUMBER(6);
	needed_qty	NUMBER(6);
	holdsum_qty	NUMBER(6);
	flag integer;

	-- cursor
	hold_list	GenCurTyp ;
BEGIN
	required_price := requested_price;
	symb_name := symbol;
	comp_name := company_name;
	flag :=1;

	-- Get information on the security
	IF symb_name = '' THEN

		comp_id := 0;
		SELECT	CO_ID
		INTO	comp_id
		FROM	COMPANY 
		WHERE	CO_NAME = comp_name;

		SELECT	S_EX_ID,
			S_NAME,
			S_SYMB
		INTO	exch_id,
			sec_name,
			symb_name
		FROM	SECURITY
		WHERE	S_CO_ID = comp_id AND
			S_ISSUE = issue;
	ELSE
		SELECT	S_CO_ID,
			S_EX_ID,
			S_NAME
		INTO	comp_id,
			exch_id,
			sec_name
		FROM	SECURITY
		WHERE	S_SYMB = symb_name;
		
		SELECT	CO_NAME
		INTO	comp_name
		FROM	COMPANY
		WHERE	CO_ID = comp_id;
	END IF;

	-- Get current pricing information for the security
	SELECT 	LT_PRICE
	INTO	market_price
	FROM	LAST_TRADE
	WHERE	LT_S_SYMB = symb_name;
	
	-- Set trade characteristics based on the type of trade.
	SELECT	TT_IS_MRKT,
		TT_IS_SELL
	INTO	type_is_market,
		type_is_sell
	FROM	TRADE_TYPE
	WHERE	TT_ID = trade_type_id;

	-- If this is a limit-order, then the requested_price was passed in to us,
    -- but
	-- if this this a market-order, then we need to set the requested_price to
    -- the current market price.
	IF type_is_market = 1 THEN
		required_price := market_price;
	END IF;

	-- Initialize variables
	buy_value := 0.0;
	sell_value := 0.0;
	needed_qty := trade_qty;

	SELECT	HS_QTY
	INTO	holdsum_qty
	FROM	HOLDING_SUMMARY
	WHERE	HS_CA_ID = acct_id AND
		HS_S_SYMB = symb_name;

	IF type_is_sell =1 THEN
	-- This is a sell transaction, so estimate the impact to any currently held
	-- long postions in the security.
	--
		IF holdsum_qty > 0 THEN
			IF is_lifo =1 THEN
				-- Estimates will be based on closing most recently acquired
				-- holdings
				-- Could return 0, 1 or many rows
				OPEN	hold_list FOR
				SELECT	H_QTY,
					H_PRICE
				FROM	HOLDING
				WHERE	H_CA_ID = acct_id AND
					H_S_SYMB = symb_name
				ORDER BY H_DTS DESC;
			ELSE
				-- Estimates will be based on closing oldest holdings
				-- Could return 0, 1 or many rows
				OPEN	hold_list FOR
				SELECT	H_QTY,
					H_PRICE
				FROM	HOLDING
				WHERE	H_CA_ID = acct_id AND
					H_S_SYMB = symb_name
				ORDER BY H_DTS ASC;
			END IF;

			-- Estimate, based on the requested price, any profit that may be
			-- realized by selling current holdings for this security. The
			-- customer may have multiple holdings for this security
			-- (representing different purchases of this security at different
			-- times and therefore, most likely, different prices).

			WHILE needed_qty > 0
			LOOP
				FETCH	hold_list
				INTO	hold_qty,
					hold_price;
				EXIT WHEN  hold_list%NOTFOUND;

				IF hold_qty > needed_qty THEN
					-- Only a portion of this holding would be sold as a
					-- result of the trade.
					buy_value := buy_value + (needed_qty * hold_price);
					sell_value := sell_value + (needed_qty * required_price);
					needed_qty := 0;
				ELSE
					-- All of this holding would be sold as a result of this
					-- trade.
					buy_value := buy_value + (hold_qty * hold_price);
					sell_value := sell_value + (hold_qty * required_price);
					needed_qty := needed_qty - hold_qty;
				END IF;
			END LOOP;

			CLOSE hold_list;
		END IF;

		-- NOTE: If needed_qty is still greater than 0 at this point, then the
		-- customer would be liquidating all current holdings for this
		-- security, and then short-selling this remaining balance for the
		-- transaction.
	ELSE
		-- This is a buy transaction, so estimate the impact to any currently
		-- held short positions in the security. These are represented as
		-- negative H_QTY holdings. Short postions will be covered before
		-- opening a long postion in this security.

		IF holdsum_qty < 0 THEN  -- Existing short position to buy

			IF is_lifo =1 THEN
				-- Estimates will be based on closing most recently acquired
				-- holdings
				-- Could return 0, 1 or many rows

				OPEN 	hold_list FOR
				SELECT	H_QTY,
					H_PRICE
				FROM	HOLDING
				WHERE	H_CA_ID = acct_id AND
					H_S_SYMB = symb_name
				ORDER BY H_DTS DESC;
			ELSE
				-- Estimates will be based on closing oldest holdings
				-- Could return 0, 1 or many rows

				OPEN	hold_list FOR
				SELECT	H_QTY,
					H_PRICE
				FROM	HOLDING
				WHERE	H_CA_ID = acct_id AND
					H_S_SYMB = symb_name
				ORDER BY H_DTS ASC;
			END IF;

			-- Estimate, based on the requested price, any profit that may be
			-- realized by covering short postions currently held for this
			-- security. The customer may have multiple holdings for this
			-- security (representing different purchases of this security at
			-- different times and therefore, most likely, different prices).

			WHILE needed_qty > 0 LOOP
				FETCH	hold_list
				INTO	hold_qty,
					hold_price;
				EXIT WHEN  hold_list%NOTFOUND;
				

				IF (hold_qty + needed_qty < 0) THEN
					-- Only a portion of this holding would be covered (bought
					-- back) as -- a result of this trade.
					sell_value := sell_value + (needed_qty * hold_price);
					buy_value := buy_value + (needed_qty * required_price);
					needed_qty := 0;

				ELSE
					-- All of this holding would be covered (bought back) as
					-- a result of this trade.
					-- NOTE: Local variable hold_qty is made positive for easy
					-- calculations
					hold_qty := -hold_qty;
					sell_value := sell_value + (hold_qty * hold_price);
					buy_value := buy_value + (hold_qty * required_price);
					needed_qty := needed_qty - hold_qty;
				END IF;
			END LOOP;

			CLOSE hold_list;
		END IF;

		-- NOTE: If needed_qty is still greater than 0 at this point, then the
		-- customer would cover all current short positions for this security,
		-- (if any) and then open a new long position for the remaining balance
		-- of this transaction.
	END IF;

	-- Estimate any capital gains tax that would be incurred as a result of this
	-- transaction.

	tax_amount := 0.0;

	IF (sell_value > buy_value) AND ((tax_status = 1) OR (tax_status = 2)) THEN
		--
		-- Customerâ€™s can be (are) subject to more than one tax rate.
		-- For example, a state tax rate and a federal tax rate. Therefore,
		-- get all tax rates the customer is subject to, and estimate overall
		-- amount of tax that would result from this order.
		--
		SELECT	sum(TX_RATE)
		INTO	tax_rates
		FROM	TAXRATE
		WHERE	TX_ID IN (
				SELECT	CX_TX_ID
				FROM	CUSTOMER_TAXRATE
				WHERE	CX_C_ID = cust_id);

		tax_amount := (sell_value - buy_value) * tax_rates;
	END IF;

	-- Get administrative fees (e.g. trading charge, commision rate)
	SELECT	CR_RATE
	INTO	comm_rate
	FROM	COMMISSION_RATE
	WHERE	CR_C_TIER = cust_tier AND
		CR_TT_ID = trade_type_id AND
		CR_EX_ID = exch_id AND
		CR_FROM_QTY <= trade_qty AND
		CR_TO_QTY >= trade_qty;

	SELECT	CH_CHRG
	INTO	charge_amount
	FROM	CHARGE
	WHERE	CH_C_TIER = cust_tier AND
		CH_TT_ID = trade_type_id;

	-- Compute assets on margin trades
	cust_assets := 0.0;

	IF type_is_margin =1 THEN
		SELECT	CA_BAL
		INTO	acct_bal
		FROM	CUSTOMER_ACCOUNT
		WHERE	CA_ID = acct_id;

		-- Should return 0 or 1 row
		SELECT	sum(HS_QTY * LT_PRICE)
		INTO	hold_assets
		FROM	HOLDING_SUMMARY,
			LAST_TRADE
		WHERE	HS_CA_ID = acct_id AND
			LT_S_SYMB = HS_S_SYMB;

		IF hold_assets is NULL THEN /* account currently has no holdings */
			cust_assets := acct_bal;
		ELSE
			cust_assets := hold_assets + acct_bal;
		END IF;
	END IF;

	-- Set the status for this trade
	IF type_is_market = 1  THEN
		status_id := st_submitted_id;
	ELSE
		status_id := st_pending_id;
	END IF;

	-- Return output parameters
	FOR rec in (SELECT	comp_name,
		required_price,
		symb_name,
		buy_value,
		charge_amount,
		comm_rate,
		cust_assets,
		market_price,
		sec_name,
		sell_value,
		status_id,
		tax_amount,
		type_is_market,
		type_is_sell from dual)
	LOOP
		TradeOrderFrame1_tbl.extend;
		TradeOrderFrame1_tbl(flag) := rec;
		flag := flag +1;
    END LOOP;
	RETURN	TradeOrderFrame1_tbl;
END;



/*
 * Frame 4
 * Responsible for for creating an audit trail record of the order 
 * and assigning a unique trade ID to it.
 */

FUNCTION TradeOrderFrame4(
				 acct_id            IN NUMBER,
				 charge_amount      IN NUMBER,
			     comm_amount        IN NUMBER,
				 exec_name          IN VARCHAR2,
				 is_cash            IN NUMBER,
				 is_lifo            IN NUMBER,
				 requested_price    IN NUMBER,
				 status_id          IN VARCHAR2,
				 symbol             IN VARCHAR2,
				 trade_qty          IN VARCHAR2,
				 trade_type_id      IN VARCHAR2,
				 type_is_market     IN NUMBER) 
RETURN NUMBER 
AS
	-- variables
	now_dts		timestamp(6);
	trade_id	NUMBER(15);
BEGIN
	-- Get the timestamp
	SELECT	CURRENT_TIMESTAMP
	INTO	now_dts from dual;

	-- Record trade information in TRADE table.
	INSERT INTO TRADE (
			T_ID, T_DTS, T_ST_ID, T_TT_ID, T_IS_CASH,
			T_S_SYMB, T_QTY, T_BID_PRICE, T_CA_ID, T_EXEC_NAME,
			T_TRADE_PRICE, T_CHRG, T_COMM, T_TAX, T_LIFO)
	VALUES 		(seq_trade_id.nextval, now_dts, status_id, trade_type_id, 
			is_cash, symbol, trade_qty, requested_price, acct_id, 
			exec_name, NULL, charge_amount, comm_amount, 0, is_lifo);

	-- Get the just generated trade id
	SELECT seq_trade_id.currval 
	INTO trade_id from dual;

	-- Record pending trade information in TRADE_REQUEST table if this trade
	-- is a limit trade

	IF type_is_market = 0 THEN
		INSERT INTO TRADE_REQUEST (
					TR_T_ID, TR_TT_ID, TR_S_SYMB,
					TR_QTY, TR_BID_PRICE, TR_B_ID)
		VALUES 			(trade_id, trade_type_id, symbol,
					trade_qty, requested_price, acct_id);
	END IF;

	-- Record trade information in TRADE_HISTORY table.
	INSERT INTO TRADE_HISTORY (
				TH_T_ID, TH_DTS, TH_ST_ID)
	VALUES (trade_id, now_dts, status_id);

	-- Return trade_id generated by SUT
	RETURN trade_id;
END;

END TradeOrderFrame1_Pkg;
/

