create or replace PACKAGE MarketFeedFrame1_Pkg AS
TYPE SYM_ARRAY is varray(100) of char(15);
TYPE PR_ARRAY is varray(100) of NUMBER(8, 2);
TYPE TR_ARRAY is varray(100) of INTEGER;

TYPE MarketFeedFrame1_record IS RECORD (
                    symbol VARCHAR2(15),
					trade_id NUMBER(15),
					price NUMBER(8,2),
					trade_quant  NUMBER(6),
					trade_type VARCHAR2(3)
                                );
TYPE MarketFeedFrame1_tab IS TABLE OF MarketFeedFrame1_record;


FUNCTION MarketFeedFrame1 (
					MaxSize		IN INTEGER,
					price_quote	IN 	PR_ARRAY,
					status_submitted	IN VARCHAR2,
					symbol		IN SYM_ARRAY,
					trade_qty		IN TR_ARRAY,
					type_limit_buy	IN VARCHAR2,
					type_limit_sell	IN VARCHAR2,
					type_stop_loss	IN VARCHAR2) 
RETURN MarketFeedFrame1_tab;

END MarketFeedFrame1_Pkg;
