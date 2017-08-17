CONNECT TPCE/TPCE;
SET SERVEROUTPUT ON;
DECLARE
frameno INTEGER;

acct_id NUMBER;
max_acct_id NUMBER;
max_trades NUMBER; 
max_updates NUMBER;
trade_dts TIMESTAMP;
symbol VARCHAR2(20);

trade_id TradeUpdateFrame1_Pkg.ARINT15;

tradeUpdateFrame1_tbl  TradeUpdateFrame1_Pkg.TradeUpdateFrame1_tab := TradeUpdateFrame1_Pkg.TradeUpdateFrame1_tab();
tradeUpdateFrame2_tbl  TradeUpdateFrame1_Pkg.TradeUpdateFrame1_tab := TradeUpdateFrame1_Pkg.TradeUpdateFrame1_tab();
tradeUpdateFrame3_tbl  TradeUpdateFrame1_Pkg.TradeUpdateFrame1_tab2 := TradeUpdateFrame1_Pkg.TradeUpdateFrame1_tab2();

BEGIN
--generate random number between 1 and 3
select dbms_random.value(1,3) num into frameno from dual;
frameno := 3;

select ca_id into acct_id from ( select ca_id, row_number() over (order by ca_id) rno from customer_account order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);
max_acct_id := acct_id;

max_trades := 10;
max_updates := 10;

select t_dts into trade_dts from ( select t_dts, row_number() over (order by t_dts) rno from trade order by rno) where  rno = ( select round (dbms_random.value (1,86400000)) from dual);
select t_s_symb into symbol from ( select t_s_symb, row_number() over (order by t_s_symb) rno from trade order by rno) where  rno = ( select round (dbms_random.value (1,86400000)) from dual);
    
SELECT t_id BULK COLLECT INTO trade_id FROM trade where rownum <=10; 

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--execute frame 1 -> is working
IF frameno = 1 then
    dbms_output.put_line('Execute frame 1');
    tradeUpdateFrame1_tbl := TradeUpdateFrame1_Pkg.TradeUpdateFrame1(max_trades, max_updates, trade_id);
    
    FOR i IN 1..tradeUpdateFrame1_tbl.count
    LOOP 
    dbms_output.put_line('num_updated   = ' || tradeUpdateFrame1_tbl(i).num_updated);
    dbms_output.put_line('num_found = ' || tradeUpdateFrame1_tbl(i).num_found);
    dbms_output.put_line('bid_price = ' || tradeUpdateFrame1_tbl(i).bid_price);
    dbms_output.put_line('exec_name = ' || tradeUpdateFrame1_tbl(i).exec_name);
    dbms_output.put_line('is_cash = ' || tradeUpdateFrame1_tbl(i).is_cash);
    dbms_output.put_line('[...]');
    END LOOP;

-- execute frame 2 -> is not working yet
ELSIF frameno = 2 then
    dbms_output.put_line('Execute frame 2');
    
    tradeUpdateFrame2_tbl := TradeUpdateFrame1_Pkg.TradeUpdateFrame2(acct_id, max_trades, max_updates, trade_dts);

--execute frame 3 -> is not working yet   
ELSIF frameno = 3 then
    dbms_output.put_line('Execute frame 3');
    
    tradeUpdateFrame3_tbl := TradeUpdateFrame1_Pkg.TradeUpdateFrame3(max_acct_id, max_trades, max_updates, trade_dts, symbol);
    
END IF;    
END;
/