CONNECT TPCE/TPCE;
SET SERVEROUTPUT ON;
DECLARE 
acct_id NUMBER;

exec_f_name VARCHAR2(20);
exec_l_name VARCHAR2(20);
exec_tax_id VARCHAR2(20);

cust_id	NUMBER;
cust_tier NUMBER;
is_lifo	NUMBER;
issue VARCHAR2(20);
st_pending_id VARCHAR2(20);
st_submitted_id	VARCHAR2(20);
tax_status NUMBER;
trade_qty NUMBER;
trade_type_id VARCHAR2(20);
type_is_margin	NUMBER;
company_name varchar2(40);
requested_price NUMBER;
symbol VARCHAR2(20);


tradeOrderFrame1_tbl  TradeOrderFrame1_Pkg.TradeOrderFrame1_tab := TradeOrderFrame1_Pkg.TradeOrderFrame1_tab();
tradeOrderFrame2_res  INTEGER;
rec TradeOrderFrame1_Pkg.TradeOrderFrame1_record;

BEGIN 
select ca_id into acct_id from ( select ca_id, row_number() over (order by ca_id) rno from customer_account order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);
select ap_f_name, ap_l_name, ap_tax_id into exec_f_name, exec_l_name, exec_tax_id from ( select ap_f_name, ap_l_name, ap_tax_id, row_number() over (order by ap_f_name, ap_l_name, ap_tax_id) rno from account_permission order by rno) where  rno = ( select round (dbms_random.value (1,35567)) from dual);
--select CX_C_ID into cust_id from ( select CX_C_ID, row_number() over (order by CX_C_ID) rno from CUSTOMER_TAXRATE order by rno) where  rno = ( select round (dbms_random.value (1,10000)) from dual);
--select CR_C_TIER into cust_tier from ( select CR_C_TIER, row_number() over (order by CR_C_TIER) rno from COMMISSION_RATE order by rno) where  rno = ( select round (dbms_random.value (1,240)) from dual);
--select co_name into company_name from ( select co_name, row_number() over (order by co_name) rno from company order by rno) where  rno = ( select round (dbms_random.value (1,2500)) from dual);
--select distinct S_ISSUE into issue from SECURITY where S_CO_ID = (select distinct co_id from company where co_name=company_name);
--is_lifo := 1;
--select st_id into st_pending_id from ( select st_id, row_number() over (order by st_id) rno from status_type order by rno) where  rno = ( select round (dbms_random.value (1,5)) from dual);
--select st_id into st_submitted_id from ( select st_id, row_number() over (order by st_id) rno from status_type order by rno) where  rno = ( select round (dbms_random.value (1,5)) from dual);



--DEBUGGING
dbms_output.put_line('acct_id:     ' || acct_id);
tradeOrderFrame1_tbl := TradeOrderFrame1_Pkg.TradeOrderFrame1(acct_id);

FOR i IN 1..tradeOrderFrame1_tbl.count
LOOP 
dbms_output.put_line('acct_name   = ' || tradeOrderFrame1_tbl(i).acct_name);
dbms_output.put_line('broker_name = ' || tradeOrderFrame1_tbl(i).broker_name);
dbms_output.put_line('[...]');
END LOOP;

tradeOrderFrame2_res := TradeOrderFrame1_Pkg.TradeOrderFrame2(acct_id, exec_f_name, exec_l_name, exec_tax_id);
END;
/