SET SERVEROUTPUT ON;
DECLARE 
in_sector_name VARCHAR2(50);
list_len INTEGER;
status INTEGER ;
i INTEGER;
testname varchar2(1000);

in_broker_list  Brokervolume_pkg.B_NAME_ARRAY := Brokervolume_pkg.B_NAME_ARRAY ();
broker_name  Brokervolume_pkg.B_NAME_ARRAY := Brokervolume_pkg.B_NAME_ARRAY ();
volume Brokervolume_pkg.VOL_ARRAY := Brokervolume_pkg.VOL_ARRAY();
brokervolframe1_tbl  Brokervolume_pkg.brokervolframe1_tab := Brokervolume_pkg.brokervolframe1_tab();
rec Brokervolume_pkg.brokervolframe1_record;
TYPE newType IS TABLE of varchar2 (255);

BEGIN 
list_len := 0;
in_sector_name  := 'Financial' ; 
SELECT b_name BULK COLLECT INTO in_broker_list FROM broker where rownum <=50; 


 
brokervolframe1_tbl := Brokervolume_pkg.BrokerVolumeFrame1(in_broker_list ,in_sector_name,broker_name,list_len,status,volume) ;
dbms_output.put_line('list_len: ' || list_len); 
dbms_output.put_line('status_out' || status);

FOR i IN 1..list_len
LOOP 
dbms_output.put_line('volume ='|| volume(i));
END LOOP; 
END;
/


