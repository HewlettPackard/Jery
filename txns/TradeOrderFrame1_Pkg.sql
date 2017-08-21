create or replace PACKAGE  TradeOrderFrame1_Pkg AS
TYPE GenCurTyp IS REF CURSOR;
TYPE  TradeOrderFrame1_record IS RECORD (
     	acct_name CUSTOMER_ACCOUNT.CA_NAME%TYPE ,
		broker_name BROKER.B_NAME%TYPE,
		cust_f_name  CUSTOMER.C_F_NAME%TYPE,
		cust_id  CUSTOMER.C_ID%TYPE, 
		cust_l_name CUSTOMER.C_F_NAME%TYPE,
		cust_tier CUSTOMER.C_TIER%TYPE,
		tax_id  CUSTOMER.C_TAX_ID%TYPE,
		tax_status CUSTOMER_ACCOUNT.CA_TAX_ST%TYPE
		);
TYPE TradeOrderFrame1_tab IS TABLE OF TradeOrderFrame1_record;

TYPE  TradeOrderFrame1_record1 IS RECORD (	
		comp_name COMPANY.CO_NAME%TYPE,
		required_price NUMBER(8,2),
		symb_name SECURITY.S_SYMB%TYPE,
		buy_value NUMBER(12,2),
		charge_amount NUMBER(10,2),
		comm_rate NUMBER(8,2),
		cust_assets NUMBER(12,2),
		market_price NUMBER(8,2),
		sec_name SECURITY.S_NAME%TYPE,
		sell_value NUMBER(12,2),
		status_id char(4),
		tax_amount NUMBER(10,2),
		type_is_market TRADE_TYPE.TT_IS_MRKT%TYPE,
		type_is_sell TRADE_TYPE.TT_IS_SELL%TYPE
		);
TYPE TradeOrderFrame1_tab1 IS TABLE OF TradeOrderFrame1_record1;

FUNCTION TradeOrderFrame1 (acct_id IN NUMBER)
RETURN TradeOrderFrame1_tab ;
FUNCTION TradeOrderFrame2(acct_id IN NUMBER,
						 exec_f_name IN varchar2,
						 exec_l_name IN varchar2,
						 exec_tax_id IN varchar2)
RETURN INTEGER;
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
RETURN TradeOrderFrame1_tab1 ;
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
RETURN NUMBER;
END TradeOrderFrame1_Pkg;
