CONNECT TPCE/TPCE
SET SERVEROUTPUT ON size 1000000;
DECLARE 
acct_id NUMBER;
cust_id NUMBER;
ending_co_id NUMBER;
industry_name VARCHAR2(50);
starting_co_id 	NUMBER;

marketWatchFrame1_tbl  MarketWatchFrame1_Pkg.MarketWatchFrame1_tab := MarketWatchFrame1_Pkg.MarketWatchFrame1_tab();
 
marketWatchFrame1rec MarketWatchFrame1_Pkg.MarketWatchFrame1_record ;
		
BEGIN

--select hs_ca_id into acct_id from ( select hs_ca_id, row_number() over (order by hs_ca_id) rno from holding_summary order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);
select hs_ca_id into acct_id from holding_summary sample(0.01) where rownum < 2;

select wl_c_id  into cust_id from ( select wl_c_id, row_number() over (order by wl_c_id) rno from watch_list order by rno) where  rno = ( select round (dbms_random.value (1,5000)) from dual);

--DEBUGGING
dbms_output.put_line('acct_id: ' || acct_id);
dbms_output.put_line('cust_id: ' || cust_id);

marketWatchFrame1_tbl := MarketWatchFrame1_Pkg.MarketWatchFrame1(acct_id, cust_id, ending_co_id, industry_name, starting_co_id);

for i in 1 .. marketWatchFrame1_tbl.count
loop 
    DBMS_OUTPUT.PUT_LINE('status here in ' || marketWatchFrame1_tbl(i).status);
end loop; 

END;