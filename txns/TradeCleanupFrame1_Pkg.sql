create or replace PACKAGE TradeCleanupFrame1_Pkg AS
TYPE GenCurTyp IS REF CURSOR;
FUNCTION TradeCleanupFrame1 (
						st_canceled_id	IN VARCHAR2,
						st_pending_id	IN VARCHAR2,
						st_submitted_id	IN VARCHAR2,
						start_trade_id	IN NUMBER)
RETURN INTEGER;		
END TradeCleanupFrame1_Pkg ;
/	
