CONNECT TPCE/TPCE
SET SERVEROUTPUT ON;
DECLARE
acct_id NUMBER;

TradeStatusFrame1_tbl  TradeStatusFrame1_Pkg.TradeStatusFrame1_tab := TradeStatusFrame1_Pkg.TradeStatusFrame1_tab(); 
TradeStatusFrame1rec TradeStatusFrame1_Pkg.TradeStatusFrame1_record ;

BEGIN 
select ca_id into acct_id from ( select ca_id, row_number() over (order by ca_id) rno from customer_account order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);

-- DEBUGGING
dbms_output.put_line('acct_id:  ' || acct_id);

TradeStatusFrame1_tbl := TradeStatusFrame1_Pkg.TradeStatusFrame1(acct_id);

--for i in 1 .. TradeStatusFrame1_tbl.count
--loop 
--DBMS_OUTPUT.PUT_LINE('cust_l_name ' || TradeStatusFrame1_tbl(i).cust_l_name);
--DBMS_OUTPUT.PUT_LINE('cust_f_name ' || TradeStatusFrame1_tbl(i).cust_f_name);
--DBMS_OUTPUT.PUT_LINE('broker_name ' || TradeStatusFrame1_tbl(i).broker_name);
--DBMS_OUTPUT.PUT_LINE('T_CHRG ' || TradeStatusFrame1_tbl(i).T_CHRG);
--DBMS_OUTPUT.PUT_LINE('T_EXEC_NAME ' || TradeStatusFrame1_tbl(i).T_EXEC_NAME);
--DBMS_OUTPUT.PUT_LINE('EX_NAME ' || TradeStatusFrame1_tbl(i).EX_NAME);
--DBMS_OUTPUT.PUT_LINE('S_NAME ' || TradeStatusFrame1_tbl(i).S_NAME);
--end loop;
END;
/