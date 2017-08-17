CONNECT TPCE/TPCE;
SET SERVEROUTPUT ON;
DECLARE 
acct_id NUMBER;

tradeOrderFrame1_tbl  TradeOrderFrame1_Pkg.TradeOrderFrame1_tab := TradeOrderFrame1_Pkg.TradeOrderFrame1_tab();
rec TradeOrderFrame1_Pkg.TradeOrderFrame1_record;

BEGIN 
select ca_id into acct_id from ( select ca_id, row_number() over (order by ca_id) rno from customer_account order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);

--DEBUGGING
dbms_output.put_line('acct_id:     ' || acct_id);
tradeOrderFrame1_tbl := TradeOrderFrame1_Pkg.TradeOrderFrame1(acct_id);

FOR i IN 1..tradeOrderFrame1_tbl.count
LOOP 
dbms_output.put_line('acct_name   = ' || tradeOrderFrame1_tbl(i).acct_name);
dbms_output.put_line('broker_name = ' || tradeOrderFrame1_tbl(i).broker_name);
dbms_output.put_line('[...]');
END LOOP; 
END;
/