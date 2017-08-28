CONNECT TPCE/TPCE;
SET SERVEROUTPUT ON;
DECLARE 
acct_id NUMBER;

exec_f_name VARCHAR2(20);
exec_l_name VARCHAR2(20);
exec_tax_id VARCHAR2(20);


tradeOrderFrame1_tbl  TradeOrderFrame1_Pkg.TradeOrderFrame1_tab := TradeOrderFrame1_Pkg.TradeOrderFrame1_tab();
tradeOrderFrame2_res  INTEGER;
tradeOrderFrame4_res  INTEGER;
rec TradeOrderFrame1_Pkg.TradeOrderFrame1_record;

BEGIN 
--select ca_id into acct_id from ( select ca_id, row_number() over (order by ca_id) rno from customer_account order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);
select ca_id into acct_id from customer_account sample(0.05) where rownum < 2;
select ap_f_name, ap_l_name, ap_tax_id into exec_f_name, exec_l_name, exec_tax_id from ( select ap_f_name, ap_l_name, ap_tax_id, row_number() over (order by ap_f_name, ap_l_name, ap_tax_id) rno from account_permission order by rno) where  rno = ( select round (dbms_random.value (1,35567)) from dual);


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