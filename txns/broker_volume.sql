create or replace PACKAGE BODY Brokervolume_pkg  AS
FUNCTION BrokerVolumeFrame1 (
		in_broker_list IN B_NAME_ARRAY,
		in_sector_name IN VARCHAR2,
		broker_name OUT B_NAME_ARRAY ,
		list_len OUT INTEGER,
		status OUT INTEGER,
		volume OUT VOL_ARRAY)
RETURN brokervolframe1_tab
AS
	brokervolframe1_tbl  brokervolframe1_tab :=brokervolframe1_tab();
	rec brokervolframe1_record;
	testname varchar2(1000);
	newTable mytableType;
	i integer;
	

BEGIN
	list_len := 0;
	testname := myANY(in_broker_list);
	--dbms_output.put_line('array: ' ||  testname);
	broker_name  := B_NAME_ARRAY ();
    volume  := VOL_ARRAY();
	newTable := myTableType();
	newTable := in_list(testname);
	
	
--	list_len := list_len + 1;
	FOR rec IN
			(SELECT b_name, SUM(tr_qty * tr_bid_price) AS volume
			FROM trade_request, sector, industry, company, broker, security
			WHERE tr_b_id = b_id
	  		AND tr_s_symb = s_symb
	  		AND s_co_id = co_id
	  		AND co_in_id = in_id
	  		AND sc_id = in_sc_id
			AND b_name IN (select * from TABLE(newTable))
			AND sc_name = in_sector_name
			GROUP BY b_name
			ORDER BY 2 DESC)
	LOOP
		brokervolframe1_tbl.extend;
	
		list_len := list_len + 1;
--		dbms_output.put_line('Inside list_len: ' ||  list_len);
--		dbms_output.put_line('rec.b_name: ' ||  rec.b_name);
--		dbms_output.put_line('rec.volume: ' ||  rec.volume);
		broker_name.extend;
		broker_name(list_len) := rec.b_name;
		volume.extend;
		volume(list_len) := rec.volume;
		brokervolframe1_tbl(list_len) := rec;
		--PIPE ROW(brokervolframe1_tbl);
	END LOOP;

	status := 0;
  
	RETURN brokervolframe1_tbl;
END BrokerVolumeFrame1;
function myANY (in_broker_list IN B_NAME_ARRAY)  
return varchar2 
as
	txt varchar2(1000);
	
begin
	--	txt := '''';
	     txt := ''''; 
		FOR indx IN in_broker_list.FIRST .. in_broker_list.LAST
		 LOOP
			--txt := txt || in_broker_list(indx) || ''',''';
			txt := txt || in_broker_list(indx) || ',';
		end LOOP;
		txt := txt || ' ''';
	--    txt := txt || ' '')';
		return txt;
		
end myANY;
 
 function in_list( p_string in varchar2 ) return myTableType 
 as 
 l_string long default p_string || ','; 
 l_data myTableType := myTableType(); 
 n number; 
 begin 
 loop 
 exit when l_string is null; 
  n := instr( l_string, ',' ); 
 l_data.extend; 
l_data(l_data.count) :=  ltrim( rtrim( substr( l_string, 1, n-1 ) ) ); 
l_string := substr( l_string, n+1 ); 
end loop; 
return l_data; 
 end in_list;
 
END Brokervolume_pkg;
/



