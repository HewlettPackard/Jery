CONNECT TPCE/TPCE;
SET SERVEROUTPUT ON;
DECLARE
st_canceled_id VARCHAR2(20);
st_pending_id VARCHAR2(20);
st_submitted_id VARCHAR2(20);
start_trade_id NUMBER;

TradeCleanupFrame1_res  INTEGER;

BEGIN
select T_ST_ID into st_canceled_id from trade sample(0.00001) where rownum < 2;
select T_ID into start_trade_id from trade sample(0.00001) where rownum < 2;

st_pending_id := st_canceled_id;
st_submitted_id := st_canceled_id;

--DEBUGGING
dbms_output.put_line('st_canceled_id   = ' || st_canceled_id);
dbms_output.put_line('st_pending_id    = ' || st_pending_id);
dbms_output.put_line('st_submitted_id  = ' || st_submitted_id);
dbms_output.put_line('start_trade_id   = ' || start_trade_id);

TradeCleanupFrame1_res := TradeCleanupFrame1_Pkg.TradeCleanupFrame1(st_canceled_id,	st_pending_id, st_submitted_id,	start_trade_id);
dbms_output.put_line('TradeCleanupFrame1_res   = ' || TradeCleanupFrame1_res);
    
END;
/