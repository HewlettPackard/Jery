create or replace PACKAGE MarketWatchFrame1_Pkg AS
TYPE GenCurTyp IS REF CURSOR;
TYPE  MarketWatchFrame1_record IS RECORD (
						status VARCHAR2(15),
						status_desc VARCHAR2(30),
						pct_change  NUMBER(2)
                                );
TYPE  MarketWatchFrame1_tab IS TABLE OF  MarketWatchFrame1_record;

FUNCTION MarketWatchFrame1 (
						acct_id		IN NUMBER,
						cust_id		IN NUMBER,
						ending_co_id IN NUMBER,
						industry_name IN VARCHAR2,
						starting_co_id 	IN NUMBER)
RETURN  MarketWatchFrame1_tab; 

END MarketWatchFrame1_Pkg;
/
