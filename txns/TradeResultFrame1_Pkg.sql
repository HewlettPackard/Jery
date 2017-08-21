create or replace PACKAGE TradeResultFrame1_Pkg AS
TYPE GenCurTyp IS REF CURSOR;
TYPE TradeResultFrame1_record IS RECORD(
		acct_id TRADE.T_CA_ID%TYPE,
		charge TRADE.T_CHRG%TYPE,
		holdsum_qty HOLDING_SUMMARY.HS_QTY%TYPE,
		is_lifo TRADE.T_LIFO%TYPE, 
		symbol TRADE.T_S_SYMB%TYPE,
		trade_is_cash TRADE.T_IS_CASH%TYPE,
		trade_qty TRADE.T_QTY%TYPE,
		type_id TRADE.T_TT_ID%TYPE,
		type_is_market TRADE_TYPE.TT_IS_MRKT%TYPE,
		type_is_sell  TRADE_TYPE.TT_IS_SELL%TYPE,
		type_name TRADE_TYPE.TT_NAME%TYPE
		);
TYPE TradeResultFrame1_record1 IS RECORD(
		broker_id CUSTOMER_ACCOUNT.CA_B_ID%TYPE,
		buy_value NUMBER(12,2),
		cust_id  CUSTOMER_ACCOUNT.CA_C_ID%TYPE,
		sell_value NUMBER(12,2),
		tax_status CUSTOMER_ACCOUNT.CA_TAX_ST%TYPE,
		year NUMBER(5,0),
		month NUMBER(5,0),
		day NUMBER(5,0),
		hour NUMBER(5,0),
		minute NUMBER(5,0),
		second NUMBER(5,0)
		);
TYPE TradeResultFrame1_record2 IS RECORD(
		comm_rate COMMISSION_RATE.CR_RATE%TYPE,
		sec_name SECURITY.S_NAME%TYPE
		);
		
TYPE TradeResultFrame1_tab is TABLE OF TradeResultFrame1_record;
TYPE TradeResultFrame1_tab1 is TABLE OF TradeResultFrame1_record1;
TYPE TradeResultFrame1_tab2 is TABLE OF TradeResultFrame1_record2;

FUNCTION TradeResultFrame1 (trade_id IN NUMBER)
RETURN TradeResultFrame1_tab;

FUNCTION TradeResultFrame2(
				acct_id	IN NUMBER,
				holdsum_qty	IN NUMBER,
				is_lifo	IN INTEGER,
				symbol IN VARCHAR2,
				trade_id	IN NUMBER,
				trade_price	IN NUMBER,
				trade_qty	IN NUMBER,
				type_is_sell	IN INTEGER) 
RETURN TradeResultFrame1_tab1 ;

FUNCTION TradeResultFrame3(
				buy_value	IN NUMBER,
				cust_id	IN NUMBER,
				sell_value	IN NUMBER,
				trade_id	IN NUMBER,
				tax_amnt	IN NUMBER) 
RETURN NUMBER ;

FUNCTION TradeResultFrame4(
				cust_id	IN NUMBER,
				symbol	IN VARCHAR2,
				trade_qty	IN NUMBER,
				type_id	IN VARCHAR2) 
RETURN TradeResultFrame1_tab2;
FUNCTION TradeResultFrame5(
				broker_id	IN NUMBER,
				comm_amount	IN NUMBER,
				st_completed_id	IN VARCHAR2,
				trade_dts		IN timestamp,
				trade_id		IN NUMBER,
				trade_price		IN NUMBER) 
RETURN integer ;
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
RETURN NUMBER;
END TradeResultFrame1_Pkg;
/
