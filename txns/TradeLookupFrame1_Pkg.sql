create or replace PACKAGE TradeLookupFrame1_Pkg AS
TYPE ARINT15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE ARTIMESTAMP IS TABLE OF TIMESTAMP(6) INDEX BY BINARY_INTEGER;
TYPE ARCHAR_4 IS TABLE OF CHAR(4) INDEX BY BINARY_INTEGER;
TYPE TradeLookupFrame1_record1 IS RECORD(
			TH_DTS  TIMESTAMP(6), 
			TH_ST_ID VARCHAR2(4)
			);

TYPE TradeLookupFrame1_record2 IS RECORD(
			    bid_price TRADE.T_BID_PRICE%TYPE,
                exec_name TRADE.T_EXEC_NAME%TYPE,
                is_cash NUMBER(5,0),
                is_market NUMBER(5,0),
                trade_price TRADE.T_TRADE_PRICE%TYPE,
                settlement_amount SETTLEMENT.SE_AMT%TYPE,
                SWC_C1 NUMBER(10,0),
                SWC_C2 NUMBER(10,0),
                SWC_C3 NUMBER(10,0),
                SWC_C4 NUMBER(10,0),
                SWC_C5 NUMBER(10,0),
                SWC_C6 NUMBER(10,0),
                settlement_cash_type SETTLEMENT.SE_CASH_TYPE%TYPE,
                cash_transaction_amount CASH_TRANSACTION.CT_AMT%TYPE,
                SWC_C7 NUMBER(10,0),
                SWC_C8 NUMBER(10,0),
                SWC_C9 NUMBER(10,0),
                SWC_C10 NUMBER(10,0),
                SWC_C11 NUMBER(10,0),
                SWC_C12 NUMBER(10,0),
                cash_transaction_name CASH_TRANSACTION.CT_NAME%TYPE,
                SWC_C13 NUMBER(10,0),
                SWC_C14 NUMBER(10,0),
                SWC_C15 NUMBER(10,0),
                SWC_C16 NUMBER(10,0),
                SWC_C17 NUMBER(10,0),
                SWC_C18 NUMBER(10,0),
                trade_history_status_id1 CHAR(4),
                SWC_C20 NUMBER(10,0),
                SWC_C21 NUMBER(10,0),
                SWC_C22 NUMBER(10,0),
                SWC_C23 NUMBER(10,0),
                SWC_C24 NUMBER(10,0),
                SWC_C25 NUMBER(10,0),
                trade_history_status_id2 CHAR(4),
                SWC_C27 NUMBER(10,0),
                SWC_C28 NUMBER(10,0),
                SWC_C29 NUMBER(10,0),
                SWC_C30 NUMBER(10,0),
                SWC_C31 NUMBER(10,0),
                SWC_C32 NUMBER(10,0),
                trade_history_status_id3 CHAR(4)
			);
TYPE TradeLookupFrame1_record3 IS RECORD(
				bid_price TRADE.T_BID_PRICE%TYPE,
				exec_name TRADE.T_EXEC_NAME%TYPE,
                is_cash NUMBER(5,0),
                trade_price TRADE.T_TRADE_PRICE%TYPE,
				T_ID TRADE.T_ID%TYPE,
                settlement_amount SETTLEMENT.SE_AMT%TYPE,
				SWC_C1 NUMBER(10,0),
                SWC_C2 NUMBER(10,0),
                SWC_C3 NUMBER(10,0),
                SWC_C4 NUMBER(10,0),
                SWC_C5 NUMBER(10,0),
                SWC_C6 NUMBER(10,0),
                settlement_cash_type SETTLEMENT.SE_CASH_TYPE%TYPE,
                cash_transaction_amount CASH_TRANSACTION.CT_AMT%TYPE,
                SWC_C7 NUMBER(10,0),
                SWC_C8 NUMBER(10,0),
                SWC_C9 NUMBER(10,0),
                SWC_C10 NUMBER(10,0),
                SWC_C11 NUMBER(10,0),
                SWC_C12 NUMBER(10,0),
                cash_transaction_name CASH_TRANSACTION.CT_NAME%TYPE,
                SWC_C13 NUMBER(10,0),
                SWC_C14 NUMBER(10,0),
                SWC_C15 NUMBER(10,0),
                SWC_C16 NUMBER(10,0),
                SWC_C17 NUMBER(10,0),
                SWC_C18 NUMBER(10,0),
                trade_history_status_id1 CHAR(4),
                SWC_C20 NUMBER(10,0),
                SWC_C21 NUMBER(10,0),
                SWC_C22 NUMBER(10,0),
                SWC_C23 NUMBER(10,0),
                SWC_C24 NUMBER(10,0),
                SWC_C25 NUMBER(10,0),
                trade_history_status_id2 CHAR(4),
                SWC_C27 NUMBER(10,0),
                SWC_C28 NUMBER(10,0),
                SWC_C29 NUMBER(10,0),
                SWC_C30 NUMBER(10,0),
                SWC_C31 NUMBER(10,0),
                SWC_C32 NUMBER(10,0),
                trade_history_status_id3 CHAR(4)
				);
			
TYPE TradeLookupFrame1_record4 IS RECORD(
            T_BID_PRICE TRADE.T_BID_PRICE%TYPE,
			T_EXEC_NAME TRADE.T_EXEC_NAME%TYPE,
			T_IS_CASH TRADE.T_IS_CASH%TYPE, 
			T_ID TRADE.T_ID%TYPE,
			T_TRADE_PRICE TRADE.T_TRADE_PRICE%TYPE
			);
TYPE TradeLookupFrame1_record5 IS RECORD(
			HH_H_T_ID HOLDING_HISTORY.HH_H_T_ID%TYPE,
			HH_T_ID  HOLDING_HISTORY.HH_T_ID%TYPE,
			HH_BEFORE_QTY HOLDING_HISTORY.HH_BEFORE_QTY%TYPE,
			HH_AFTER_QTY HOLDING_HISTORY.HH_AFTER_QTY%TYPE,
			TRADE_ID TRADE.T_ID%TYPE
			);
TYPE TradeLookupFrame1_record6 IS RECORD(
			T_CA_ID TRADE.T_CA_ID%TYPE,
			T_EXEC_NAME TRADE.T_EXEC_NAME%TYPE,
			T_IS_CASH TRADE.T_IS_CASH%TYPE,
			T_ID TRADE.T_ID%TYPE,
			T_TRADE_PRICE TRADE.T_TRADE_PRICE%TYPE,
			T_QTY TRADE.T_QTY%TYPE,
			T_DTS TRADE.T_DTS%TYPE,
			T_TT_ID TRADE.T_TT_ID%TYPE
			);
TYPE TradeLookupFrame1_record7 IS RECORD(
					   T_CA_ID TRADE.T_CA_ID%TYPE, 
					   cash_transaction_amount CASH_TRANSACTION.CT_AMT%TYPE,
				       SWC_C7 NUMBER(10,0),
                       SWC_C8 NUMBER(10,0),
                       SWC_C9 NUMBER(10,0),
                       SWC_C10 NUMBER(10,0),
                       SWC_C11 NUMBER(10,0),
                       SWC_C12 NUMBER(10,0),
				       cash_transaction_name CASH_TRANSACTION.CT_NAME%TYPE, 
					   T_EXEC_NAME TRADE.T_EXEC_NAME%TYPE,
				       T_IS_CASH TRADE.T_IS_CASH%TYPE, 
					   T_TRADE_PRICE TRADE.T_TRADE_PRICE%TYPE,
					   T_QTY TRADE.T_QTY%TYPE,
				       settlement_amount SETTLEMENT.SE_AMT%TYPE, 
					   SWC_C1 NUMBER(10,0),
                       SWC_C2 NUMBER(10,0),
                       SWC_C3 NUMBER(10,0),
                       SWC_C4 NUMBER(10,0),
                       SWC_C5 NUMBER(10,0),
                       SWC_C6 NUMBER(10,0),
				       settlement_cash_type SETTLEMENT.SE_CASH_TYPE%TYPE, 
					   SWC_C33 NUMBER(10,0),
					   SWC_C34 NUMBER(10,0),
                       SWC_C35 NUMBER(10,0),
                       SWC_C36 NUMBER(10,0),
                       SWC_C37 NUMBER(10,0),
                       SWC_C38 NUMBER(10,0),
			           SWC_C13 NUMBER(10,0),
                       SWC_C14 NUMBER(10,0),
                       SWC_C15 NUMBER(10,0),
                       SWC_C16 NUMBER(10,0),
                       SWC_C17 NUMBER(10,0),
                       SWC_C18 NUMBER(10,0),
                       trade_history_status_id1 CHAR(4),
                       SWC_C20 NUMBER(10,0),
                       SWC_C21 NUMBER(10,0),
                       SWC_C22 NUMBER(10,0),
                       SWC_C23 NUMBER(10,0),
                       SWC_C24 NUMBER(10,0),
                       SWC_C25 NUMBER(10,0),
                       trade_history_status_id2 CHAR(4),
                       SWC_C27 NUMBER(10,0),
                       SWC_C28 NUMBER(10,0),
                       SWC_C29 NUMBER(10,0),
                       SWC_C30 NUMBER(10,0),
                       SWC_C31 NUMBER(10,0),
                       SWC_C32 NUMBER(10,0),
                       trade_history_status_id3 CHAR(4) ,
					   T_ID TRADE.T_ID%TYPE, 
					   T_TT_ID TRADE.T_TT_ID%TYPE
            );
TYPE TradeLookupFrame1_tab is TABLE OF TradeLookupFrame1_record2;
TYPE TradeLookupFrame1_tab1 is TABLE OF TradeLookupFrame1_record3;
TYPE TradeLookupFrame1_tab2 is TABLE OF TradeLookupFrame1_record7;
TYPE TradeLookupFrame1_tab3 is TABLE OF TradeLookupFrame1_record5;
FUNCTION TradeLookupFrame1(max_trades IN NUMBER, trade_id IN ARINT15 )
RETURN TradeLookupFrame1_tab;
FUNCTION TradeLookupFrame2(	acct_id	IN NUMBER,	max_trades	IN integer,	trade_dts	IN timestamp)
RETURN TradeLookupFrame1_tab1;
FUNCTION TradeLookupFrame3( max_acct_id IN NUMBER, max_trades IN INTEGER, TRADE_DTS in TIMESTAMP,SYMBOL IN VARCHAR2)
RETURN TradeLookupFrame1_tab2;
FUNCTION TradeLookupFrame4(acct_id	IN NUMBER,trade_dts	 IN timestamp)
RETURN TradeLookupFrame1_tab3;

END TradeLookupFrame1_Pkg;
/
