CONNECT TPCE/TPCE;
SET SERVEROUTPUT ON;
DECLARE
lowerBound NUMBER;
upperBound NUMBER;
max_trades INTEGER;
trade_id TradeLookupFrame1_Pkg.ARINT15 ;

tradeLookupFrame1_tbl  TradeLookupFrame1_Pkg.TradeLookupFrame1_tab := TradeLookupFrame1_Pkg.TradeLookupFrame1_tab();

BEGIN 
max_trades :=10;
SELECT dbms_random.value(max_trades,79488129) num into upperBound FROM dual;
lowerBound := upperBound - max_trades;

-- DEBUGGING
dbms_output.put_line('max_trades:  ' || max_trades);
dbms_output.put_line('lowerBound:  ' || lowerBound);
dbms_output.put_line('upperBound:  ' || upperBound);

SELECT t_id BULK COLLECT INTO trade_id FROM ( SELECT t_id , row_number() over (order by t_id) rno FROM trade)
                            WHERE  rno <= upperBound 
                            AND rno >= lowerBound;

for i in 1 .. trade_id.count
loop 
DBMS_OUTPUT.PUT_LINE('trade_id ' || i || ' ' || trade_id(i));
end loop;

tradeLookupFrame1_tbl := TradeLookupFrame1_Pkg.TradeLookupFrame1(max_trades, trade_id);
for i in 1 .. tradeLookupFrame1_tbl.count
loop 

DBMS_OUTPUT.PUT_LINE('bid_price here in ' || tradeLookupFrame1_tbl(i).bid_price);
DBMS_OUTPUT.PUT_LINE('exec_name here in ' || tradeLookupFrame1_tbl(i).exec_name);
end loop;


END;
/