CREATE OR REPLACE PACKAGE BODY SecurityDetailFrame1_Pkg as
FUNCTION SecurityDetailFrame1 (
						access_lob_flag	IN INTEGER,
						max_rows_to_return	IN INTEGER,
						start_day IN DATE,
						symbol	IN 	VARCHAR2)
RETURN SecurityDetailFrame1_tab
AS
	SecurityDetailFrame1_tbl  SecurityDetailFrame1_tab := SecurityDetailFrame1_tab();
	rec1 SecurityDetailFrame1_record1;
	rec2 SecurityDetailFrame1_record2;
	rec3 SecurityDetailFrame1_record3;
	rec4 SecurityDetailFrame1_record4;
	rec5 SecurityDetailFrame1_record5;
	-- output parameters
	cp_co_name	 VARCHAR2(150);
	cp_in_name	VARCHAR2(150);
	fin_year	VARCHAR2(500);
	fin_qtr		VARCHAR2(500);
	fin_start_year	VARCHAR2(500);
	fin_start_month	VARCHAR2(500);
	fin_start_day	VARCHAR2(500);
	fin_start_hour	VARCHAR2(500);
	fin_start_min	VARCHAR2(500);
	fin_start_sec	VARCHAR2(500);
	fin_rev		VARCHAR2(400);
	fin_net_earn	VARCHAR2(400);
	fin_basic_eps	VARCHAR2(400);
	fin_dilut_eps	VARCHAR2(400);
	fin_margin	VARCHAR2(400);
	fin_invent	VARCHAR2(400);
	fin_assets	VARCHAR2(400);
	fin_liab	VARCHAR2(400);
	fin_out_basic	VARCHAR2(400);
	fin_out_dilut	VARCHAR2(400);
	day_date_year	VARCHAR2(500);
	day_date_month	VARCHAR2(500);
	day_date_day	VARCHAR2(500);
	day_date_hour	VARCHAR2(500);
	day_date_minute	VARCHAR2(500);
	day_date_second	VARCHAR2(500);
	day_close	VARCHAR2(500);
	day_high	VARCHAR2(500);
	day_low		VARCHAR2(500);
	day_vol		VARCHAR2(500);
	news_it		BLOB;
	news_it_convert1 VARCHAR2(4000);
	news_it_convert2 VARCHAR2(4000);
	news_year	VARCHAR2(50);
	news_month	VARCHAR2(50);
	news_day	VARCHAR2(50);
	news_hour	VARCHAR2(50);
	news_minute	VARCHAR2(50);
	news_second	VARCHAR2(50);
	news_src	VARCHAR2(60);
	news_auth	VARCHAR2(60);
	news_headline	VARCHAR2(160);
	news_summary	VARCHAR2(520);
	last_price	NUMBER(10,2);
	last_open	NUMBER(10,2);
	last_vol	NUMBER(12);
	fin_len		integer;
	day_len		integer;
	news_len	integer;
	new_blob BLOB;

	-- variables
	comp_id		NUMBER(11);
	
	i		integer;
	flag integer;
	
	
BEGIN

	dbms_lob.createtemporary(new_blob, TRUE);
	-- initialize text variables
	cp_co_name := '';
	cp_in_name := '';
	fin_year := '';
	fin_qtr := '';
	fin_start_year := '';
	fin_start_month := '';
	fin_start_day := '';
	fin_start_hour := '';
	fin_start_min := '';
	fin_start_sec := '';
	fin_rev := '';
	fin_net_earn := '';
	fin_basic_eps := '';
	fin_dilut_eps := '';
	fin_margin := '';
	fin_invent := '';
	fin_assets := '';
	fin_liab := '';
	fin_out_basic := '';
	fin_out_dilut := '';
	day_date_year := '';
	day_date_month := '';
	day_date_day := '';
	day_date_hour := '';
	day_date_minute := '';
	day_date_second := '';
	day_close := '';
	day_high := '';
	day_low	 := '';
	day_vol	 := '';
	--news_it	 := '';
	news_it_convert1 :='';
	news_it_convert2 :='';
	news_year := '';
	news_month := '';
	news_day := '';
	news_hour := '';
	news_minute := '';
	news_second := '';
	news_src := '';
	news_auth := '';
	news_headline := '';
	news_summary := '';
	--SecurityDetailFrame1_tbl.extend;

	-- get company id from symbol

	SELECT	CO_ID
	INTO	comp_id
	FROM	SECURITY,
		COMPANY
	WHERE	S_SYMB = symbol AND
		S_CO_ID = CO_ID;

	-- Should return max_comp_len rows

	FOR rec1 IN
		(SELECT	CO_NAME,
			IN_NAME
		FROM	COMPANY_COMPETITOR,
			COMPANY,
			INDUSTRY
		WHERE	CP_CO_ID = comp_id AND
			CO_ID = CP_COMP_CO_ID AND
			IN_ID = CP_IN_ID
		    and rownum <=3)
	LOOP
		cp_co_name := cp_co_name || '|' || rec1.CO_NAME;
		cp_in_name := cp_in_name || '|' || rec1.IN_NAME;
	END LOOP;

	-- Should return max_fin_len rows
	
	i := 0;
	FOR rec2 IN
		(SELECT	FI_YEAR,
			FI_QTR,
			extract(year from FI_QTR_START_DATE)  year,
			extract(month from FI_QTR_START_DATE) month,
			extract(day from FI_QTR_START_DATE)  day,
			extract(hour from CAST(FI_QTR_START_DATE as TIMESTAMP))  hour,
			extract(minute from CAST(FI_QTR_START_DATE as TIMESTAMP))  minute,
			extract(second from CAST(FI_QTR_START_DATE as TIMESTAMP))  second,
			FI_REVENUE,
			FI_NET_EARN,
			FI_BASIC_EPS,
			FI_DILUT_EPS,
			FI_MARGIN,
			FI_INVENTORY,
			FI_ASSETS,
			FI_LIABILITY,
			FI_OUT_BASIC,
			FI_OUT_DILUT
		FROM	FINANCIAL
		WHERE	FI_CO_ID = comp_id and rownum <=20
		ORDER BY FI_YEAR asc, FI_QTR)
	LOOP
		fin_year := fin_year || '|' || rec2.FI_YEAR;
		fin_qtr := fin_qtr || '|' || rec2.FI_QTR;
		fin_start_year := fin_start_year || '|' || rec2.year;
		fin_start_month := fin_start_month || '|' || rec2.month;
		fin_start_day := fin_start_day || '|' || rec2.day;
		fin_start_hour := fin_start_hour || '|' || rec2.hour;
		fin_start_min := fin_start_min || '|' || rec2.minute;
		fin_start_sec := fin_start_sec || '|' || rec2.second;
		fin_rev := fin_rev || '|' || rec2.FI_REVENUE;
		fin_net_earn := fin_net_earn || '|' || rec2.FI_NET_EARN;
		fin_basic_eps := fin_basic_eps || '|' || rec2.FI_BASIC_EPS;
		fin_dilut_eps := fin_dilut_eps || '|' || rec2.FI_DILUT_EPS;
		fin_margin := fin_margin || '|' || rec2.FI_MARGIN;
		fin_invent := fin_invent || '|' || rec2.FI_INVENTORY;
		fin_assets := fin_assets || '|' || rec2.FI_ASSETS;
		fin_liab := fin_liab || '|' || rec2.FI_LIABILITY;
		fin_out_basic := fin_out_basic || '|' || rec2.FI_OUT_BASIC;
		fin_out_dilut := fin_out_dilut || '|' || rec2.FI_OUT_DILUT;
		i := i + 1;
	END LOOP;

	fin_len := i;

	-- Should return max_rows_to_return rows
	
	i := 0;
	
	FOR rec3 IN
		(SELECT	extract(year from DM_DATE) as year,
			extract(month from DM_DATE) as month,
			extract(day from DM_DATE) as day,
			extract(hour from CAST(DM_DATE as TIMESTAMP)) as hour,
			extract(minute from CAST(DM_DATE as TIMESTAMP)) as minute,
			extract(second from CAST(DM_DATE as TIMESTAMP)) as second,
			DM_CLOSE,
			DM_HIGH,
			DM_LOW,
			DM_VOL
		FROM	DAILY_MARKET
		WHERE	DM_S_SYMB = symbol AND
			DM_DATE >= start_day and rownum <= max_rows_to_return
		ORDER BY DM_DATE asc)
		
	LOOP
		day_date_year := day_date_year || '|' || rec3.year;
		day_date_month := day_date_month || '|' || rec3.month;
		day_date_day := day_date_day || '|' || rec3.day;
		day_date_hour := day_date_hour || '|' || rec3.hour;
		day_date_minute := day_date_minute || '|' || rec3.minute;
		day_date_second := day_date_second || '|' || rec3.second;
		day_close := day_close || '|' || rec3.DM_CLOSE;
		day_high := day_high || '|' || rec3.DM_HIGH;
		day_low := day_low || '|' || rec3.DM_LOW;
		day_vol := day_vol || '|' || rec3.DM_VOL;
		i := i + 1;
	END LOOP;

	day_len := i;

	SELECT	LT_PRICE,
		LT_OPEN_PRICE,
		LT_VOL
	INTO	last_price,
		last_open,
		last_vol
	FROM	LAST_TRADE
	WHERE	LT_S_SYMB = symbol and rownum <=max_rows_to_return;
	
	
	-- Should return max_news_len rows
	
	i := 0;
    flag :=1;
	IF access_lob_flag = 1 THEN
		FOR rec4 IN
			(SELECT	NI_ITEM,
				extract(year from NI_DTS) as year,
				extract(month from NI_DTS) as month,
				extract(day from NI_DTS) as day,
				extract(hour from NI_DTS) as hour,
				extract(minute from NI_DTS) as minute,
				extract(second from NI_DTS) as second,
				NI_SOURCE,
				NI_AUTHOR
			FROM	NEWS_XREF,
				NEWS_ITEM
			WHERE	NI_ID = NX_NI_ID AND
				NX_CO_ID = comp_id
			    and rownum <=2)
		LOOP
		
			DBMS_LOB.APPEND(new_blob,rec4.NI_ITEM);
		
			
			news_year := news_year || '|' || rec4.year;
			news_month := news_month || '|' || rec4.month;
			news_day := news_day || '|' || rec4.day;
			news_hour := news_hour || '|' || rec4.hour;
			news_minute := news_minute || '|' || rec4.minute;
			news_second := news_second || '|' || rec4.second;
			news_src := news_src || '|' || rec4.NI_SOURCE;
			news_auth := news_auth || '|' || rec4.NI_AUTHOR;
			news_headline := news_headline || '|' || '';
			news_summary := news_summary || '|' || '';
			
			i := i + 1;
		END LOOP;
			news_it := new_blob;
	ELSE
		FOR rec4 IN
			(SELECT	extract(year from NI_DTS) as year,
				extract(month from NI_DTS) as month,
				extract(day from NI_DTS) as day,
				extract(hour from NI_DTS) as hour,
				extract(minute from NI_DTS) as minute,
				extract(second from NI_DTS) as second,
				NI_SOURCE,
				NI_AUTHOR,
				NI_HEADLINE,
				NI_SUMMARY
			FROM	NEWS_XREF,
				NEWS_ITEM
			WHERE	NI_ID = NX_NI_ID AND
				NX_CO_ID = comp_id
			    and rownum <=2)
		LOOP
			--news_it := news_it || '|' || '';
			news_year := news_year || '|' || rec4.year;
			news_month := news_month || '|' || rec4.month;
			news_day := news_day || '|' || rec4.day;
			news_hour := news_hour || '|' || rec4.hour;
			news_minute := news_minute || '|' || rec4.minute;
			news_second := news_second || '|' || rec4.second;
			news_src := news_src || '|' || rec4.NI_SOURCE;
			news_auth := news_auth || '|' || rec4.NI_AUTHOR;
			news_headline := news_headline || '|' || rec4.NI_HEADLINE;
			news_summary := news_summary || '|' || rec4.NI_SUMMARY;
			i := i + 1;
		END LOOP;
		    news_it := new_blob;
	END IF;
	
	news_len := i;
	flag :=1;
  
	FOR rec5 in 
	(SELECT	fin_len,
		day_len,
		news_len,
		cp_co_name,
		cp_in_name,
		fin_year,
		fin_qtr,
		fin_start_year,
		fin_start_month,
		fin_start_day,
		fin_start_hour,
		fin_start_min,
		fin_start_sec,
		fin_rev,
		fin_net_earn,
		fin_basic_eps,
		fin_dilut_eps,
		fin_margin,
		fin_invent,
		fin_assets,
		fin_liab,
		fin_out_basic,
		fin_out_dilut,
		day_date_year,
		day_date_month,
		day_date_day,
		day_date_hour,
		day_date_minute,
		day_date_second,
		day_close,
		day_high,
		day_low,
		day_vol,
		news_it,
		news_year,
		news_month,
		news_day,
		news_hour,
		news_minute,
		news_second,
		news_src,
		news_auth,
		news_headline,
		news_summary,
		last_price,
		last_open,
		last_vol,
		S_NAME,
		CO_ID,
		CO_NAME,
		CO_SP_RATE,
		CO_CEO,
		CO_DESC,
		extract(year from CO_OPEN_DATE) as year1,
		extract(month from CO_OPEN_DATE) as month1,
		extract(day from CO_OPEN_DATE) as day1,
		extract(hour from CAST(CO_OPEN_DATE as TIMESTAMP)) as hour1,
		extract(minute from CAST(CO_OPEN_DATE as TIMESTAMP)) as minute1,
		extract(second from CAST(CO_OPEN_DATE as TIMESTAMP)) as second1,
		CO_ST_ID,
		CA.AD_LINE1 as ca_ad_line1,
		CA.AD_LINE2 as ca_ad_line2,
		ZCA.ZC_TOWN as zca_zc_town,
		ZCA.ZC_DIV  as zca_zc_div,
		CA.AD_ZC_CODE as ca_ad_zc_code,
		CA.AD_CTRY  as ca_ad_ctry,
		S_NUM_OUT,
		extract(year from S_START_DATE) as year2,
		extract(month from S_START_DATE) as month2,
		extract(day from S_START_DATE) as day2,
		extract(hour from CAST(S_START_DATE as TIMESTAMP)) as hour2,
		extract(minute from CAST(S_START_DATE as TIMESTAMP)) as minute2,
		extract(second from CAST(S_START_DATE as TIMESTAMP)) as second2,
		extract(year from S_EXCH_DATE) as year3,
		extract(month from S_EXCH_DATE) as month3,
		extract(day from S_EXCH_DATE) as day3,
		extract(hour from CAST(S_EXCH_DATE as TIMESTAMP)) as hour3,
		extract(minute from CAST(S_EXCH_DATE as TIMESTAMP)) as minute3,
		extract(second from CAST(S_EXCH_DATE as TIMESTAMP)) as second3,
		S_PE,
		S_52WK_HIGH,
		extract(year from S_52WK_HIGH_DATE) as year4,
		extract(month from S_52WK_HIGH_DATE) as month4,
		extract(day from S_52WK_HIGH_DATE) as day4,
		extract(hour from CAST(S_52WK_HIGH_DATE as TIMESTAMP)) as hour4,
		extract(minute from CAST(S_52WK_HIGH_DATE as TIMESTAMP)) as minute4,
		extract(second from CAST(S_52WK_HIGH_DATE as TIMESTAMP)) as second4,
		S_52WK_LOW,
		extract(year from S_52WK_LOW_DATE) as year5,
		extract(month from S_52WK_LOW_DATE) as month5,
		extract(day from S_52WK_LOW_DATE) as day5,
		extract(hour from CAST(S_52WK_LOW_DATE as TIMESTAMP)) as hour5,
		extract(minute from CAST(S_52WK_LOW_DATE as TIMESTAMP)) as minute5,
		extract(second from CAST(S_52WK_LOW_DATE as TIMESTAMP)) as second5,
		S_DIVIDEND,
		S_YIELD,
		ZEA.ZC_DIV as zea_zc_div,
		EA.AD_CTRY as ea_ad_ctry,
		EA.AD_LINE1 as ea_ad_line1,
		EA.AD_LINE2 as ea_ad_line2,
		ZEA.ZC_TOWN as zea_zc_town,
		EA.AD_ZC_CODE as ea_ad_zc_code,
		EX_CLOSE,
		EX_DESC,
		EX_NAME,
		EX_NUM_SYMB,
		EX_OPEN
		FROM	SECURITY,
		COMPANY,
		ADDRESS CA,
		ADDRESS EA,
		ZIP_CODE ZCA,
		ZIP_CODE ZEA,
		EXCHANGE
	WHERE	S_SYMB = symbol AND
		CO_ID = S_CO_ID AND
		CA.AD_ID = CO_AD_ID AND
		EA.AD_ID = EX_AD_ID AND
		EX_ID = S_EX_ID AND
		ca.ad_zc_code = zca.zc_code AND
		ea.ad_zc_code = zea.zc_code)
	LOOP
		SecurityDetailFrame1_tbl.extend;
		SecurityDetailFrame1_tbl(flag) := rec5;
	   flag := flag + 1;
	END LOOP;

		
	RETURN SecurityDetailFrame1_tbl;
END SecurityDetailFrame1 ;
END SecurityDetailFrame1_Pkg ;
