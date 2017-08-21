create or replace PACKAGE Brokervolume_pkg AS
TYPE B_NAME_ARRAY is varray(50) of varchar2(100);
TYPE B_NAME_TYPE IS TABLE OF B_NAME_ARRAY;
TYPE VOL_ARRAY is varray(50) of NUMBER(14, 2);
TYPE str_tbl is table of varchar2(100);
TYPE myTableType IS TABLE of varchar2 (255);
TYPE brokervolframe1_record IS RECORD (
                b_name VARCHAR2(100) ,
                volume NUMBER(38,2)
                                );
TYPE brokervolframe1_tab IS TABLE OF brokervolframe1_record;
FUNCTION BrokerVolumeFrame1 (
		in_broker_list IN B_NAME_ARRAY,
		in_sector_name IN VARCHAR2,
		broker_name OUT B_NAME_ARRAY ,
		list_len OUT INTEGER,
		status OUT INTEGER,
		volume OUT VOL_ARRAY)
RETURN brokervolframe1_tab ;

function myANY (in_broker_list IN B_NAME_ARRAY)
return varchar2;

function in_list( p_string in varchar2 )
return myTableType;

END Brokervolume_pkg ;
/
