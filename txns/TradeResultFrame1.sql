CREATE OR REPLACE PACKAGE BODY TradeResultFrame1_Pkg AS
FUNCTION TradeResultFrame1 (trade_id IN NUMBER)
RETURN TradeResultFrame1_tab 
AS 
	-- output parameters
	acct_id		NUMBER(11);
	charge		NUMBER(10,2);
	holdsum_qty	NUMBER(6);
	is_lifo		smallint;
	symbol		CHAR(15);
	trade_is_cash	NUMBER(1);
	trade_qty	NUMBER(6);
	type_id		char(3);
	type_is_market	NUMBER(1);	
	type_is_sell	NUMBER(1);
	type_name	char(12);
	i integer;

	-- variables
	TradeResultFrame1_tbl TradeResultFrame1_tab := TradeResultFrame1_tab();
	rec TradeResultFrame1_record ;
BEGIN
    i :=1;
	SELECT  T_CA_ID,
		T_TT_ID,
		T_S_SYMB,
		T_QTY,
		T_CHRG,
		T_LIFO,
		T_IS_CASH
	INTO	acct_id,
		type_id,
		symbol,
		trade_qty,
		charge,
		is_lifo,
		trade_is_cash
	FROM	TRADE
	WHERE	T_ID = trade_id;

	SELECT	TT_NAME,
		TT_IS_SELL,
		TT_IS_MRKT
	INTO	type_name,
		type_is_sell,
		type_is_market
	FROM	TRADE_TYPE
	WHERE	TT_ID = type_id;

	SELECT	HS_QTY
	INTO	holdsum_qty
	FROM	HOLDING_SUMMARY
	WHERE	HS_CA_ID = acct_id AND
		HS_S_SYMB = symbol;

	IF holdsum_qty is NULL THEN -- no prior holdings exist
		holdsum_qty := 0;
	END IF;

	-- return data
	FOR rec in (SELECT acct_id,
		charge,
		holdsum_qty,
		is_lifo,
		symbol,
		trade_is_cash,
		trade_qty,
		type_id,
		type_is_market,
		type_is_sell,
		type_name from dual)
    LOOP
		TradeResultFrame1_tbl.extend;
		TradeResultFrame1_tbl(i) := rec;
		i := i + 1;
	END LOOP;
		

	RETURN	TradeResultFrame1_tbl;
END;



/*
 * Frame 2
 * responsible for modifying the customer's holdings to reflect the result
 * of a buy or a sell trade.
 */

FUNCTION TradeResultFrame2(
				acct_id	IN NUMBER,
				holdsum_qty	IN NUMBER,
				is_lifo	IN INTEGER,
				symbol IN VARCHAR2,
				trade_id	IN NUMBER,
				trade_price	IN NUMBER,
				trade_qty	IN NUMBER,
				type_is_sell	IN INTEGER) 
RETURN TradeResultFrame1_tab1 
AS 

	-- output parameters
	broker_id	NUMBER(11);
	buy_value	NUMBER(12,2);
	cust_id		NUMBER(11);
	sell_value	NUMBER(12,2);
	tax_status	INTEGER;
	trade_dts	timestamp(6);

	-- variables
	hold_id		NUMBER(11);
	hold_price	NUMBER(8,2);
	hold_qty	NUMBER(6);
	needed_qty	NUMBER(6);
	TradeResultFrame1_tbl TradeResultFrame1_tab1 := TradeResultFrame1_tab1();
	rec TradeResultFrame1_record1 ;
	i integer;
	-- cursor
	hold_list	GenCurTyp;
BEGIN
	i :=1;
	-- Get the timestamp
	SELECT	CURRENT_TIMESTAMP 
	INTO	trade_dts from dual;

	-- Initialize variables
	buy_value := 0.0;
	sell_value := 0.0;
	needed_qty := trade_qty;

	SELECT	CA_B_ID,
		CA_C_ID,
		CA_TAX_ST
	INTO	broker_id,
		cust_id,
		tax_status
	FROM	CUSTOMER_ACCOUNT
	WHERE	CA_ID = acct_id;

	-- Determine if sell or buy order
	IF type_is_sell =1  THEN 

		IF holdsum_qty = 0 THEN
			-- no prior holdings exist, but one will be inserted
			INSERT INTO	HOLDING_SUMMARY (
						HS_CA_ID,
						HS_S_SYMB,
						HS_QTY)
			VALUES 		(acct_id, symbol, (-1)*trade_qty);
		ELSE
			IF holdsum_qty != trade_qty THEN
				UPDATE	HOLDING_SUMMARY
				SET	HS_QTY = (holdsum_qty- trade_qty)
				WHERE	HS_CA_ID = acct_id AND
					HS_S_SYMB = symbol;
			END IF;
		END IF;

		-- Sell Trade:
		-- First look for existing holdings, H_QTY > 0
		IF holdsum_qty > 0 THEN

			IF is_lifo =1 THEN
				-- Could return 0, 1 or many rows
				OPEN 	hold_list FOR
				SELECT	H_T_ID,
					H_QTY,
					H_PRICE
				FROM	HOLDING
				WHERE	H_CA_ID = acct_id AND
					H_S_SYMB = symbol
				ORDER BY H_DTS desc;
			ELSE
				-- Could return 0, 1 or many rows
				OPEN	hold_list FOR
				SELECT	H_T_ID,
					H_QTY,
					H_PRICE
				FROM	HOLDING
				WHERE	H_CA_ID = acct_id AND
					H_S_SYMB = symbol
				ORDER BY H_DTS asc;
			END IF;

			-- Liquidate existing holdings. Note that more than
			-- 1 HOLDING record can be deleted here since customer
			-- may have the same security with differing prices.
			
			WHILE needed_qty > 0 LOOP
				FETCH	hold_list
				INTO	hold_id,
					hold_qty,
					hold_price;
				EXIT WHEN  hold_list%NOTFOUND;

				IF hold_qty > needed_qty THEN
					-- Selling some of the holdings
					INSERT INTO	HOLDING_HISTORY (
								HH_H_T_ID,
								HH_T_ID,
								HH_BEFORE_QTY,
								HH_AFTER_QTY)
					VALUES (		hold_id, -- H_T_ID of original trade
								trade_id, -- T_ID current trade
								hold_qty, -- H_QTY now
								(hold_qty - needed_qty)); -- H_QTY after update
					
					UPDATE	HOLDING
					SET	H_QTY = (hold_qty - needed_qty)
					WHERE	H_T_ID = hold_id; -- current of hold_list;

					buy_value := buy_value + (needed_qty * hold_price);
					sell_value := sell_value + (needed_qty * trade_price);
					needed_qty := 0;
				ELSE
					-- Selling all holdings
					INSERT INTO	HOLDING_HISTORY (
								HH_H_T_ID,
								HH_T_ID,
								HH_BEFORE_QTY,
								HH_AFTER_QTY)
					VALUES (		hold_id, -- H_T_ID original trade
								trade_id, -- T_ID current trade
								hold_qty, -- H_QTY now
								0); -- H_QTY after delete
					
					DELETE FROM	HOLDING
					WHERE		H_T_ID = hold_id; -- current of hold_list;

					buy_value := buy_value + (hold_qty * hold_price);
					sell_value := sell_value + (hold_qty * trade_price);
					needed_qty := needed_qty - hold_qty;
				END IF;
			END LOOP;

			CLOSE	hold_list;
		END IF;

		-- Sell Short:
		-- If needed_qty > 0 then customer has sold all existing
		-- holdings and customer is selling short. A new HOLDING
		-- record will be created with H_QTY set to the negative
		-- number of needed shares.

		IF needed_qty > 0 THEN
			INSERT INTO	HOLDING_HISTORY (
						HH_H_T_ID,
						HH_T_ID,
						HH_BEFORE_QTY,
						HH_AFTER_QTY)
			VALUES (		trade_id, -- T_ID current is original trade
						trade_id, -- T_ID current trade
						0, -- H_QTY before
						(-1) * needed_qty); -- H_QTY after insert
			
			INSERT INTO	HOLDING (
						H_T_ID,
						H_CA_ID,
						H_S_SYMB,
						H_DTS,
						H_PRICE,
						H_QTY)
			VALUES (		trade_id, -- H_T_ID
						acct_id, -- H_CA_ID
						symbol, -- H_S_SYMB
						trade_dts, -- H_DTS
						trade_price, -- H_PRICE
						(-1) * needed_qty); -- * H_QTY
		ELSE
			IF holdsum_qty = trade_qty THEN
				DELETE FROM	HOLDING_SUMMARY
				WHERE		HS_CA_ID = acct_id AND
						HS_S_SYMB = symbol;
			END IF;
		END IF;

	ELSE -- The trade is a BUY

		IF holdsum_qty = 0 THEN
			-- no prior holdings exist, but one will be inserted
			INSERT INTO	HOLDING_SUMMARY (
						HS_CA_ID,
						HS_S_SYMB,
						HS_QTY)
			VALUES (		acct_id,
						symbol,
						trade_qty);
		ELSE -- holdsum_qty != 0
			IF -holdsum_qty != trade_qty THEN
				UPDATE	HOLDING_SUMMARY
				SET	HS_QTY = holdsum_qty + trade_qty
				WHERE	HS_CA_ID = acct_id AND
					HS_S_SYMB = symbol;
			END IF;
		END IF;

		-- Short Cover:
		-- First look for existing negative holdings, H_QTY < 0,
		-- which indicates a previous short sell. The buy trade
		-- will cover the short sell.

		IF holdsum_qty < 0 THEN
			IF is_lifo =1  THEN
				-- Could return 0, 1 or many rows
				OPEN 	hold_list FOR
				SELECT	H_T_ID,
					H_QTY,
					H_PRICE
				FROM	HOLDING
				WHERE	H_CA_ID = acct_id AND
					H_S_SYMB = symbol
				ORDER BY H_DTS desc;
			ELSE
				-- Could return 0, 1 or many rows
				OPEN 	hold_list FOR
				SELECT	H_T_ID,
					H_QTY,
					H_PRICE
				FROM	HOLDING
				WHERE	H_CA_ID = acct_id AND
					H_S_SYMB = symbol
				ORDER BY H_DTS asc;
			END IF;

			-- Buy back securities to cover a short position.
			
			WHILE needed_qty > 0 LOOP
				FETCH	hold_list
				INTO	hold_id,
					hold_qty,
					hold_price;
				EXIT WHEN  hold_list%NOTFOUND;

				IF (hold_qty + needed_qty < 0) THEN
					-- Buying back some of the Short Sell
					INSERT INTO	HOLDING_HISTORY (
								HH_H_T_ID,
								HH_T_ID,
								HH_BEFORE_QTY,
								HH_AFTER_QTY)
					VALUES (		hold_id, -- H_T_ID original trade
								trade_id, -- T_ID current trade
								hold_qty, -- H_QTY now
								(hold_qty + needed_qty)); -- H_QTY after update
					
					UPDATE	HOLDING
					SET	H_QTY = (hold_qty + needed_qty)
					WHERE	H_T_ID = hold_id;	--current of hold_list;
	
					sell_value := sell_value + (needed_qty * hold_price);
					buy_value := buy_value + (needed_qty * trade_price);
					needed_qty := 0;
				ELSE
					-- Buying back all of the Short Sell
					INSERT INTO	HOLDING_HISTORY (
								HH_H_T_ID,
								HH_T_ID,
								HH_BEFORE_QTY,
								HH_AFTER_QTY)
					VALUES (		hold_id, -- H_T_ID original trade
								trade_id, -- T_ID current trade
								hold_qty, -- H_QTY now
								0); -- H_QTY after delete
					
					DELETE FROM	HOLDING
					WHERE		H_T_ID = hold_id;	--current of hold_list;
	
					-- Make hold_qty positive for easy calculations
					hold_qty := -hold_qty;
					sell_value := sell_value + (hold_qty * hold_price);
					buy_value := buy_value + (hold_qty * trade_price);
					needed_qty := needed_qty - hold_qty;
				END IF;
			END LOOP;
			CLOSE	hold_list;
		END IF;

		-- Buy Trade:
		-- If needed_qty > 0, then the customer has covered all
		-- previous Short Sells and the customer is buying new
		-- holdings. A new HOLDING record will be created with
		-- H_QTY set to the number of needed shares.
	
		IF needed_qty > 0 THEN
			INSERT INTO	HOLDING_HISTORY (
						HH_H_T_ID,
						HH_T_ID,
						HH_BEFORE_QTY,
						HH_AFTER_QTY)
			VALUES (		trade_id, -- T_ID current is original trade
						trade_id, -- * T_ID current trade
						0, -- H_QTY before
						needed_qty); -- H_QTY after insert
			
			INSERT INTO	HOLDING (
						H_T_ID, 
						H_CA_ID,
						H_S_SYMB,
						H_DTS,
						H_PRICE,
						H_QTY)
			VALUES (		trade_id, -- H_T_ID
						acct_id, -- H_CA_ID
						symbol, -- H_S_SYMB
						trade_dts, -- H_DTS
						trade_price, -- H_PRICE
						needed_qty); -- H_QTY
		ELSE
			IF (-holdsum_qty = trade_qty) THEN
				DELETE FROM	HOLDING_SUMMARY
				WHERE		HS_CA_ID = acct_id AND
						HS_S_SYMB = symbol;
			END IF;
		END IF;

	END IF;

	-- Return output parameters
	FOR rec in (SELECT	broker_id,
		buy_value,
		cust_id,
		sell_value,
		tax_status,
		extract(year from trade_dts) as year,
		extract(month from trade_dts) as month,
		extract(day from trade_dts) as day,
		extract(hour from trade_dts) as hour,
		extract(minute from trade_dts) as minute,
		extract(second from trade_dts) as second from dual)
    LOOP
		TradeResultFrame1_tbl.extend;
		TradeResultFrame1_tbl(i) := rec;
		i := i + 1;
	END LOOP;
	
	RETURN	TradeResultFrame1_tbl;

END;

/*
 * Frame 3
 * Responsible for computing the amount of tax due by the customer as a result
 * of the trade
 * 
 */

FUNCTION TradeResultFrame3(
				buy_value	IN NUMBER,
				cust_id	IN NUMBER,
				sell_value	IN NUMBER,
				trade_id	IN NUMBER,
				tax_amnt	IN NUMBER) 
RETURN NUMBER 
AS 
	-- Local Frame variables
	tax_rates	NUMBER(8,2);
	tax_amount	NUMBER(10,2);
BEGIN
	tax_amount := tax_amnt;

	SELECT	sum(TX_RATE)
	INTO	tax_rates
	FROM	TAXRATE
	WHERE	TX_ID IN ( SELECT	CX_TX_ID
			FROM	CUSTOMER_TAXRATE
			WHERE	CX_C_ID = cust_id);

	tax_amount := tax_rates * (sell_value - buy_value);

	UPDATE	TRADE
	SET	T_TAX = tax_amount
	WHERE	T_ID = trade_id;

	RETURN round(tax_amount,2);
END TradeResultFrame3;



/*
 * Frame 4
 * responsible for computing the commission for the broker who executed the
 * trade.
 * 
 */

FUNCTION TradeResultFrame4(
				cust_id	IN NUMBER,
				symbol	IN VARCHAR2,
				trade_qty	IN NUMBER,
				type_id	IN VARCHAR2) 
RETURN TradeResultFrame1_tab2
AS
	-- Local Frame variables
	cust_tier	NUMBER(38);
	sec_ex_id	char(6);
	TradeResultFrame1_tbl TradeResultFrame1_tab2 := TradeResultFrame1_tab2();
	rec TradeResultFrame1_record2 ;
	i integer;

	-- output parameters
	comm_rate	NUMBER(5,2);
	sec_name	varchar2(70);
	
BEGIN
	SELECT	S_EX_ID,
		S_NAME
	INTO	sec_ex_id,
		sec_name
	FROM	SECURITY
	WHERE	S_SYMB = symbol;

	SELECT	C_TIER
	INTO	cust_tier
	FROM	CUSTOMER
	WHERE	C_ID = cust_id;

	-- Only want 1 commission rate row
	SELECT	CR_RATE
	INTO	comm_rate
	FROM	COMMISSION_RATE
	WHERE	CR_C_TIER = cust_tier AND
		CR_TT_ID = type_id AND
		CR_EX_ID = sec_ex_id AND
		CR_FROM_QTY <= trade_qty AND
		CR_TO_QTY >= trade_qty and rownum <=1;
	
	FOR rec in (SELECT	comm_rate,
		sec_name from dual)
	LOOP
		TradeResultFrame1_tbl.extend;
		TradeResultFrame1_tbl(i) := rec;
		i := i + 1;
	END LOOP;
		

	RETURN	TradeResultFrame1_tbl;

END TradeResultFrame4;



/*
 * Frame 5
 * responsible for recording the result of the trade and the broker's
 * commission.
 * 
 */

FUNCTION TradeResultFrame5(
				broker_id	IN NUMBER,
				comm_amount	IN NUMBER,
				st_completed_id	IN VARCHAR2,
				trade_dts		IN timestamp,
				trade_id		IN NUMBER,
				trade_price		IN NUMBER) 
RETURN integer 
AS 
	
BEGIN
	UPDATE	TRADE
	SET	T_COMM = comm_amount,
		T_DTS = trade_dts,
		T_ST_ID = st_completed_id,
		T_TRADE_PRICE = trade_price
	WHERE	T_ID = trade_id;

	INSERT INTO	TRADE_HISTORY (
					TH_T_ID,
					TH_DTS,
					TH_ST_ID)
	VALUES (trade_id, trade_dts, st_completed_id);
	
	UPDATE	BROKER
	SET	B_COMM_TOTAL = B_COMM_TOTAL + comm_amount,
		B_NUM_TRADES = B_NUM_TRADES + 1
	WHERE	B_ID = broker_id;
	
	RETURN 0;
END TradeResultFrame5;



/*
 * Frame 6
 * responsible for settling the trade.
 * 
 */

FUNCTION TradeResultFrame6(
				acct_id		IN NUMBER ,
				due_date		IN timestamp,
				s_name		IN varchar2,
				se_amount    IN NUMBER,
				trade_dts	IN	timestamp,
				trade_id		IN NUMBER,
				trade_is_cash	IN INTEGER,
				trade_qty		IN NUMBER,
				type_name		IN VARCHAR2) 
RETURN NUMBER
AS 
	-- Local Frame Variables
	cash_type	char(40);

	-- output parameter
	acct_bal		NUMBER(12,2);
BEGIN
	IF trade_is_cash=1  THEN
		cash_type := 'Cash Account';
	ELSE
		cash_type := 'Margin';
	END IF;

	INSERT INTO SETTLEMENT (SE_T_ID, SE_CASH_TYPE, SE_CASH_DUE_DATE, SE_AMT)
	VALUES (trade_id, cash_type, due_date, se_amount);

	IF trade_is_cash =1  THEN
		UPDATE	CUSTOMER_ACCOUNT
		SET	CA_BAL = (CA_BAL + se_amount)
		WHERE	CA_ID = acct_id;

		INSERT INTO CASH_TRANSACTION (CT_DTS, CT_T_ID, CT_AMT, CT_NAME)
		VALUES (trade_dts, trade_id, se_amount,
		        (type_name || ' ' || trade_qty || ' shares of ' || s_name) );
	END IF;

	SELECT	CA_BAL
	INTO	acct_bal
	FROM	CUSTOMER_ACCOUNT
	WHERE	CA_ID = acct_id;

	RETURN	round(acct_bal,2);
END TradeResultFrame6;

END TradeResultFrame1_Pkg;
/

