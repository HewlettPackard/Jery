CONNECT TPCE/TPCE
SET SERVEROUTPUT ON;
DECLARE 
in_acct_id NUMBER;
in_c_id NUMBER;
in_co_id NUMBER;
day_of_month INTEGER;
symbol VARCHAR2(50);
table_name VARCHAR2(50);
in_tx_id VARCHAR2(50);
vol_incr INTEGER;
status INTEGER;

dataMaintenanceFrame1_out INTEGER;

BEGIN 
select ap_ca_id into in_acct_id from ( select ap_ca_id, row_number() over (order by ap_ca_id) rno from account_permission order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);
select c_id into in_c_id from ( select c_id, row_number() over (order by c_id) rno from customer order by rno) where  rno = ( select round (dbms_random.value (1,5000)) from dual);
select co_id into in_co_id from ( select co_id, row_number() over (order by co_id) rno from company order by rno) where  rno = ( select round (dbms_random.value (1,2500)) from dual);
select round (dbms_random.value (1, 31)) into day_of_month from dual;
select dm_s_symb into symbol from ( select dm_s_symb, row_number() over (order by dm_s_symb) rno from daily_market order by rno) where  rno = ( select round (dbms_random.value (1,3425)) from dual);
with tablenames as (
      select 'ACCOUNT_PERMISSION' as s from dual union all
      select 'ADDRESS' as s from dual union all
      select 'COMPANY' as s from dual union all
      select 'CUSTOMER' as s from dual union all
      select 'CUSTOMER_TAXRATE' as s from dual union all
      select 'DAILY_MARKET' as s from dual union all
      select 'FINANCIAL' as s from dual union all
      select 'NEWS_ITEM' as s from dual union all
      select 'SECURITY' as s from dual union all
      select 'TAXRATE' as s from dual union all
      select 'WATCH_ITEM' as s from dual
     )
select (select s
        from (select s from tablenames order by dbms_random.value) s
        where rownum = 1
       )
into table_name       
from dual;
select tx_id into in_tx_id from ( select tx_id, row_number() over (order by tx_id) rno from taxrate order by rno) where  rno = ( select round (dbms_random.value (0,320)) from dual);
select dm_vol into vol_incr from ( select dm_vol, row_number() over (order by dm_vol) rno from daily_market order by rno) where  rno = ( select round (dbms_random.value (1,4469625)) from dual);

-- DEBUGGING
dbms_output.put_line('in_acct_id:   ' || in_acct_id);
dbms_output.put_line('in_c_id:      ' || in_c_id);
dbms_output.put_line('in_co_id:     ' || in_co_id);
dbms_output.put_line('day_of_month: ' || day_of_month);
dbms_output.put_line('symbol:       ' || symbol);
dbms_output.put_line('table_name:   ' || table_name);
dbms_output.put_line('in_tx_id:     ' || in_tx_id);
dbms_output.put_line('vol_incr:     ' || vol_incr);

dataMaintenanceFrame1_out := DataMaintenanceFrame1_Pkg.DataMaintenanceFrame1(in_acct_id, in_c_id, in_co_id, day_of_month, symbol, table_name, in_tx_id, vol_incr, status);

dbms_output.put_line('status ' || dataMaintenanceFrame1_out);

END;