CONNECT TPCE/TPCE
SET SERVEROUTPUT ON;
DECLARE 

access_lob_flag INTEGER;
max_rows_to_return INTEGER;
start_day DATE;
symbol VARCHAR2(50);

end_date DATE;
		
securityDetailFrame1_tbl SecurityDetailFrame1_Pkg.SecurityDetailFrame1_tab := SecurityDetailFrame1_Pkg.SecurityDetailFrame1_tab();
 
securityDetailFrame1rec SecurityDetailFrame1_Pkg.SecurityDetailFrame1_record1 ;

BEGIN 
access_lob_flag := 1;
select round (dbms_random.value (5, 20)) into max_rows_to_return from dual;
end_date := DATE '2005-01-01';
end_date := end_date - max_rows_to_return;
select s_symb into symbol from ( select s_symb, row_number() over (order by s_symb) rno from security order by rno) where  rno = ( select round (dbms_random.value (1,3425)) from dual);
select TO_DATE(
              trunc(
                   DBMS_RANDOM.VALUE(TO_CHAR(DATE '2000-01-03','J')
                                    ,TO_CHAR(end_date,'J')
                                    )
                    ),'J'
               ) into start_day from DUAL;

-- DEBUGGING
dbms_output.put_line('access_lob_flag:     ' || access_lob_flag);
dbms_output.put_line('max_rows_to_return:  ' || max_rows_to_return);
dbms_output.put_line('start_day:           ' || start_day);
dbms_output.put_line('symbol:              ' || symbol);


securityDetailFrame1_tbl := SecurityDetailFrame1_Pkg.SecurityDetailFrame1(access_lob_flag, max_rows_to_return, start_day, symbol);

END;