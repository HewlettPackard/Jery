SET SERVEROUTPUT ON;
DECLARE 
		cust_id   NUMBER(11);
		tax_id  VARCHAR(20);
		acct_len  INTEGER;
		c_ad_id  NUMBER(11); 
		c_area_1  VARCHAR(3);
		c_area_2  VARCHAR(3);
		c_area_3  VARCHAR(3);
		c_ctry_1  VARCHAR(3); 
		c_ctry_2  VARCHAR(3);
		c_ctry_3  VARCHAR(3);
	--	c_dob  DATE;
		c_email_1  VARCHAR(50);
		c_email_2  VARCHAR(50);
		c_ext_1  VARCHAR(5);
		c_ext_2  VARCHAR(5);
		c_ext_3  VARCHAR(5);
		c_f_name  VARCHAR(30);
		c_gndr  VARCHAR(1);
		c_l_name  VARCHAR(30);
		c_local_1  VARCHAR(10);
		c_local_2  VARCHAR(10);
		c_local_3  VARCHAR(10);
		c_m_name  VARCHAR(1);
		c_st_id  VARCHAR(4);
		c_tier  NUMBER(38);
		status  INTEGER;
acct_id CustomerPosition_pkg.ID_ARRAY :=	CustomerPosition_pkg.ID_ARRAY();
asset_total CustomerPosition_pkg.TOT_ARRAY :=	CustomerPosition_pkg.TOT_ARRAY();
cash_bal CustomerPosition_pkg.TOT_ARRAY :=	CustomerPosition_pkg.TOT_ARRAY();	
c_dob DATE := SYSDATE ;
		
customerPositionFrame1_tbl  CustomerPosition_pkg.CustomerPositionFrame1_tab := CustomerPosition_pkg.CustomerPositionFrame1_tab();
 
customerFramerec CustomerPosition_pkg.CustomerPositionFrame1_record ;



BEGIN 

cust_id := 4300000001;
tax_id  := 'TAX ID';
 
customerPositionFrame1_tbl := CustomerPosition_pkg.CustomerPositionFrame1(cust_id ,tax_id ,acct_id ,acct_len ,asset_total ,c_ad_id,c_area_1  ,c_area_2  ,c_area_3  ,	c_ctry_1  ,c_ctry_2  ,c_ctry_3  ,	c_dob ,c_email_1  ,	c_email_2  ,	c_ext_1  ,c_ext_2  ,c_ext_3  ,c_f_name  ,	c_gndr  ,c_l_name  ,c_local_1  ,c_local_2  ,	c_local_3  ,c_m_name  ,c_st_id ,c_tier ,cash_bal ,	status  );

dbms_output.put_line('list_len: ' || acct_len); 
dbms_output.put_line('status_' || status);
FOR i IN 1 .. acct_len
LOOP 
dbms_output.put_line('acct_id '|| acct_id(i));
dbms_output.put_line('cash_bal '|| cash_bal(i));
dbms_output.put_line('asset_total '|| asset_total(i));
END LOOP; 
END;
/




