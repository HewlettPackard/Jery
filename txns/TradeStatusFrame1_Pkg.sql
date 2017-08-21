create or replace PACKAGE  TradeStatusFrame1_Pkg  AS
TYPE TradeStatusFrame1_record IS RECORD(
			cust_l_name CUSTOMER.C_L_NAME%TYPE,
			cust_f_name CUSTOMER.C_F_NAME%TYPE,
			broker_name BROKER.B_NAME%TYPE,
			T_CHRG TRADE.T_CHRG%TYPE,
			T_EXEC_NAME TRADE.T_EXEC_NAME%TYPE,
			EX_NAME EXCHANGE.EX_NAME%TYPE,
			S_NAME SECURITY.S_NAME%TYPE,
			ST_NAME status_type.st_name%type,
			T_S_SYMB trade.T_S_SYMB%TYPE,
			year  NUMBER(5),
			month  NUMBER(5),
			day  NUMBER(5),
			hour  NUMBER(5),
			minute  NUMBER(5),
			second  NUMBER(5),
			T_ID TRADE.T_ID%TYPE,
			T_QTY TRADE.T_QTY%TYPE,
			TT_NAME TRADE_TYPE.TT_NAME%TYPE
			);
TYPE TradeStatusFrame1_tab is TABLE OF TradeStatusFrame1_record;
FUNCTION TradeStatusFrame1 (acct_id IN NUMBER)
RETURN TradeStatusFrame1_tab;
END TradeStatusFrame1_Pkg;
