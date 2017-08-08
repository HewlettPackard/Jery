CREATE OR REPLACE PACKAGE BODY  MarketFeedFrame1_Pkg
AS 
FUNCTION MarketFeedFrame1 (
					MaxSize		IN INTEGER,
					price_quote	IN 	PR_ARRAY,
					status_submitted	IN VARCHAR2,
					symbol		IN SYM_ARRAY,
					trade_qty		IN TR_ARRAY,
					type_limit_buy	IN VARCHAR2,
					type_limit_sell	IN VARCHAR2,
					type_stop_loss	IN VARCHAR2) 
RETURN  MarketFeedFrame1_tab
IS 
	-- output parameters
	rec	MarketFeedFrame1_record;
	TradeRequestBuffer MarketFeedFrame1_tab := MarketFeedFrame1_tab();

	-- variables
	i			integer;
	list_len integer;
--	now_dts			timestamp;
	now_dts TIMESTAMP(6):=systimestamp;
	
	trade_id		NUMBER(15);
	price			numeric(8,2);
	trade_type		char(3);
	trade_quant		integer;
	
	CURSOR  request_list (i in integer)
	IS
			SELECT	TR_T_ID, TR_BID_PRICE,
				TR_TT_ID,
				TR_QTY
				FROM	TRADE_REQUEST
				WHERE	TR_S_SYMB = symbol(i) and 
						(
						(TR_TT_ID = type_stop_loss and TR_BID_PRICE >= price_quote(i)) or
						(TR_TT_ID =  type_limit_sell and TR_BID_PRICE <= price_quote(i)) or
						(TR_TT_ID = type_limit_buy and TR_BID_PRICE >= price_quote(i))
						);
BEGIN
	
	
    --now_dts = now();
	list_len:= 0;
	FOR i IN 1..MaxSize 
	LOOP
		-- start transaction
		UPDATE	LAST_TRADE
		SET	LT_PRICE = price_quote(i),
			LT_VOL = LT_VOL + trade_qty(i),
			LT_DTS = now_dts
		WHERE	LT_S_SYMB = symbol(i);

        OPEN request_list(i);

		FETCH	request_list
		INTO	trade_id,
			price,
			trade_type,
			trade_quant;
			

		WHILE request_list%FOUND
		LOOP
			UPDATE	TRADE
			SET	T_DTS = now_dts,
				T_ST_ID = status_submitted
			WHERE	T_ID = trade_id;
		
			DELETE	FROM TRADE_REQUEST
			WHERE	TR_T_ID = trade_id;

			INSERT INTO TRADE_HISTORY
			VALUES (trade_id, now_dts, status_submitted);

			
				rec.symbol := symbol(i);
				rec.trade_id :=	trade_id;
				rec.price :=	price;
				rec.trade_quant := 	trade_quant;
				rec.trade_type :=	trade_type;
			
			
				TradeRequestBuffer.extend;
				list_len := list_len + 1;
				TradeRequestBuffer(list_len) := rec;
				--RETURN NEXT TradeRequestBuffer;
			
		
			FETCH	request_list
			INTO	trade_id,
				price,
				trade_type,
				trade_quant;
				
		END LOOP;
         	
	
		CLOSE request_list;
		-- commit transaction
	END LOOP;
	
	RETURN  TradeRequestBuffer;
	
END  MarketFeedFrame1;

END  MarketFeedFrame1_Pkg;
/

