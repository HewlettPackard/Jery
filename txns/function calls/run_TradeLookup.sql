CONNECT TPCE/TPCE;
SET SERVEROUTPUT ON;
DECLARE
frameno INTEGER;

max_trades INTEGER;
trade_id TradeLookupFrame1_Pkg.ARINT15;
acct_id NUMBER;
trade_dts TIMESTAMP;
max_acct_id NUMBER;
symbol VARCHAR2(20);

tradeLookupFrame1_tbl  TradeLookupFrame1_Pkg.TradeLookupFrame1_tab := TradeLookupFrame1_Pkg.TradeLookupFrame1_tab();
tradeLookupFrame2_tbl  TradeLookupFrame1_Pkg.TradeLookupFrame1_tab1 := TradeLookupFrame1_Pkg.TradeLookupFrame1_tab1();
tradeLookupFrame3_tbl  TradeLookupFrame1_Pkg.TradeLookupFrame1_tab2 := TradeLookupFrame1_Pkg.TradeLookupFrame1_tab2();
tradeLookupFrame4_tbl  TradeLookupFrame1_Pkg.TradeLookupFrame1_tab3 := TradeLookupFrame1_Pkg.TradeLookupFrame1_tab3();

BEGIN
--generate random number between 1 and 4
select dbms_random.value(1,4) num into frameno from dual;
frameno := 4;

max_trades := 10;
SELECT t_id BULK COLLECT INTO trade_id FROM trade where rownum <=10;
select ca_id into acct_id from ( select ca_id, row_number() over (order by ca_id) rno from customer_account order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);
max_acct_id := acct_id;
select t_dts into trade_dts from ( select t_dts, row_number() over (order by t_dts) rno from trade order by rno) where  rno = ( select round (dbms_random.value (1,86400000)) from dual);
select t_s_symb into symbol from ( select t_s_symb, row_number() over (order by t_s_symb) rno from trade order by rno) where  rno = ( select round (dbms_random.value (1,86400000)) from dual);


-------------------------------------------------------------------------------------------------------------------------
--execute frame 1 -> is working
IF frameno = 1 then
    tradeLookupFrame1_tbl := TradeLookupFrame1_Pkg.TradeLookupFrame1(max_trades, trade_id);
    for i in 1 .. tradeLookupFrame1_tbl.count
    loop    
    DBMS_OUTPUT.PUT_LINE('bid_price here in ' || tradeLookupFrame1_tbl(i).bid_price);
    DBMS_OUTPUT.PUT_LINE('exec_name here in ' || tradeLookupFrame1_tbl(i).exec_name);
    end loop;

--execute frame 2 -> is not working yet   
ELSIF frameno = 2 then
    dbms_output.put_line('Execute frame 2');
    
    tradeLookupFrame2_tbl := TradeLookupFrame1_Pkg.TradeLookupFrame2(acct_id, max_trades, trade_dts);

--execute frame 3 -> is not working yet 
ELSIF frameno = 3 then
    dbms_output.put_line('Execute frame 3');
    
    tradeLookupFrame3_tbl := TradeLookupFrame1_Pkg.TradeLookupFrame3(max_acct_id, max_trades, trade_dts, symbol);

--execute frame 4 -> is not working 
ELSIF frameno = 4 then
    dbms_output.put_line('Execute frame 4');
    
    tradeLookupFrame4_tbl := TradeLookupFrame1_Pkg.TradeLookupFrame4(acct_id, trade_dts);
    
END IF;
END;
/