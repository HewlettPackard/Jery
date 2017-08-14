CREATE OR REPLACE PACKAGE BODY TradeCleanupFrame1_Pkg AS
FUNCTION TradeCleanupFrame1(
						st_canceled_id	IN VARCHAR2,
						st_pending_id	IN VARCHAR2,
						st_submitted_id	IN VARCHAR2,
						start_trade_id	IN NUMBER)
RETURN integer
AS
	-- variables
	trade_id	NUMBER(15);
	tr_trade_id	NUMBER(15);
	--now_dts		timestamp;
	now_dts TIMESTAMP(6):=systimestamp;

	pending_list	GenCurTyp;
	submit_list	GenCurTyp;
BEGIN
	/* Find pending trades from TRADE_REQUEST */

	OPEN pending_list FOR
	SELECT	TR_T_ID
	FROM	TRADE_REQUEST
	ORDER BY TR_T_ID;

	/* Insert a submitted followed by canceled record into TRADE_HISTORY, mark
       the trade canceled and delete the pending trade */

	FETCH	pending_list
	INTO	tr_trade_id;

	WHILE pending_list%FOUND 
	LOOP
		--now_dts = now();
         now_dts := systimestamp;
		INSERT INTO TRADE_HISTORY (TH_T_ID, TH_DTS, TH_ST_ID)
		VALUES (tr_trade_id, now_dts, st_submitted_id);

		UPDATE	TRADE
		SET	T_ST_ID = st_canceled_id,
			T_DTS = now_dts
		WHERE	T_ID = tr_trade_id;

		INSERT INTO TRADE_HISTORY (TH_T_ID, TH_DTS, TH_ST_ID)
		VALUES (tr_trade_id, now_dts, st_canceled_id);

		FETCH	pending_list
		INTO	tr_trade_id;
	END LOOP;

	/* Remove all pending trades */

	DELETE FROM TRADE_REQUEST;

	/* Find submitted trades, change the status to canceled and insert a
       canceled record into TRADE_HISTORY*/

	OPEN submit_list FOR
	SELECT	T_ID
	FROM	TRADE
	WHERE	T_ID >= start_trade_id AND
		T_ST_ID = st_submitted_id;

	FETCH	submit_list
	INTO	trade_id;

	WHILE submit_list%FOUND 
	LOOP
		--now_dts = now();
         now_dts :=systimestamp;
		/* Mark the trade as canceled, and record the time */

		UPDATE	TRADE
		SET	T_ST_ID = st_canceled_id,
			T_DTS = now_dts
		WHERE	T_ID = trade_id;

		INSERT INTO TRADE_HISTORY (TH_T_ID, TH_DTS, TH_ST_ID)
		VALUES (trade_id, now_dts, st_canceled_id);

		FETCH	submit_list
		INTO	trade_id;
	END LOOP;

	RETURN 0;
END TradeCleanupFrame1;
END TradeCleanupFrame1_Pkg;
/

