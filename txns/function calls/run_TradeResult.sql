CONNECT TPCE/TPCE;
SET SERVEROUTPUT ON;
DECLARE 
trade_id NUMBER;

tradeResultFrame1_tbl  TradeResultFrame1_Pkg.TradeResultFrame1_tab := TradeResultFrame1_Pkg.TradeResultFrame1_tab();
rec TradeResultFrame1_Pkg.TradeResultFrame1_record;

BEGIN 
select t_id into trade_id from ( select t_id, row_number() over (order by t_id) rno from trade order by rno) where  rno = ( select round (dbms_random.value (1,86400000)) from dual);

--DEBUGGING
dbms_output.put_line('trade_id:   ' || trade_id);
tradeResultFrame1_tbl := TradeResultFrame1_Pkg.TradeResultFrame1(trade_id);

FOR i IN 1..tradeResultFrame1_tbl.count
LOOP 
dbms_output.put_line('acct_id     = ' || tradeResultFrame1_tbl(i).acct_id);
dbms_output.put_line('charge      = ' || tradeResultFrame1_tbl(i).charge);
dbms_output.put_line('holdsum_qty = ' || tradeResultFrame1_tbl(i).holdsum_qty);
dbms_output.put_line('is_lifo     = ' || tradeResultFrame1_tbl(i).is_lifo);
dbms_output.put_line('[...]');
END LOOP; 
END;
/