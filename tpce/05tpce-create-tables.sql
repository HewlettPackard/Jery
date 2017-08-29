CREATE TABLE tpce.account_permission (
    ap_ca_id NUMBER(11) NOT NULL,
    ap_acl VARCHAR2(4) NOT NULL,
    ap_tax_id VARCHAR2(20) NOT NULL,
    ap_l_name VARCHAR2(30) NOT NULL,
    ap_f_name VARCHAR2(30) NOT NULL);
    

-- Clause 2.2.5.2
CREATE TABLE tpce.customer (
    c_id NUMBER(11) NOT NULL,
    c_tax_id VARCHAR2(20) NOT NULL,
    c_st_id VARCHAR2(4) NOT NULL,
    c_l_name VARCHAR2(30) NOT NULL,
    c_f_name VARCHAR2(30) NOT NULL,
    c_m_name VARCHAR2(1),
    c_gndr VARCHAR2(1),
    c_tier SMALLINT NOT NULL,
    c_dob DATE NOT NULL,
    c_ad_id NUMBER(11) NOT NULL,
    c_ctry_1 VARCHAR2(3),
    c_area_1 VARCHAR2(3),
    c_local_1 VARCHAR2(10),
    c_ext_1 VARCHAR2(5),
    c_ctry_2 VARCHAR2(3),
    c_area_2 VARCHAR2(3),
    c_local_2 VARCHAR2(10),
    c_ext_2 VARCHAR2(5),
    c_ctry_3 VARCHAR2(3),
    c_area_3 VARCHAR2(3),
    c_local_3 VARCHAR2(10),
    c_ext_3 VARCHAR2(5),
    c_email_1 VARCHAR2(50),
    c_email_2 VARCHAR2(50));
    

-- Clause 2.2.5.3
CREATE TABLE tpce.customer_account (
    ca_id NUMBER(11) NOT NULL,
    ca_b_id NUMBER(11) NOT NULL,
    ca_c_id NUMBER(11) NOT NULL,
    ca_name VARCHAR2(50),
    ca_tax_st SMALLINT NOT NULL,
    ca_bal NUMBER(12,2) NOT NULL);
    

-- Clause 2.2.5.4
CREATE TABLE tpce.customer_taxrate (
    cx_tx_id VARCHAR2(4) NOT NULL,
    cx_c_id NUMBER(11) NOT NULL);
    

-- Clause 2.2.5.5
CREATE TABLE tpce.holding (
    h_t_id NUMBER(15) NOT NULL,
    h_ca_id NUMBER(11) NOT NULL,
    h_s_symb VARCHAR2(15) NOT NULL,
    h_dts TIMESTAMP NOT NULL,
    h_price NUMBER(8,2) NOT NULL CHECK (h_price > 0),
    h_qty NUMBER(6) NOT NULL);
    

-- Clause 2.2.5.6
CREATE TABLE tpce.holding_history (
    hh_h_t_id NUMBER(15) NOT NULL,
    hh_t_id NUMBER(15) NOT NULL,
    hh_before_qty NUMBER(6) NOT NULL,
    hh_after_qty NUMBER(6) NOT NULL);
    

-- Clause 2.2.5.7
CREATE TABLE tpce.holding_summary (
    hs_ca_id NUMBER(11) NOT NULL,
    hs_s_symb VARCHAR2(15) NOT NULL,
    hs_qty NUMBER(6) NOT NULL);
    

-- Clause 2.2.5.8
CREATE TABLE tpce.watch_item (
    wi_wl_id NUMBER(11) NOT NULL,
    wi_s_symb VARCHAR2(15) NOT NULL);
    

-- Clause 2.2.5.9
CREATE TABLE tpce.watch_list (
    wl_id NUMBER(11) NOT NULL,
    wl_c_id NUMBER(11) NOT NULL);
    

-- Broker Tables

-- Clause 2.2.6.1
CREATE TABLE tpce.broker (
    b_id NUMBER(11) NOT NULL,
    b_st_id VARCHAR2(4) NOT NULL,
    b_name VARCHAR2(100) NOT NULL,
    b_num_trades INTEGER NOT NULL,
    b_comm_total NUMBER(12,2) NOT NULL);
    

-- Clause 2.2.6.2
CREATE TABLE tpce.cash_transaction (
    ct_t_id NUMBER(15) NOT NULL,
    ct_dts TIMESTAMP NOT NULL,
    ct_amt NUMBER(10,2) NOT NULL,
    ct_name VARCHAR2(100));
    

-- Clause 2.2.6.3
CREATE TABLE tpce.charge (
    ch_tt_id VARCHAR2(3) NOT NULL,
    ch_c_tier SMALLINT,
    ch_chrg NUMBER(10,2) CHECK (ch_chrg > 0));
    

-- Clause 2.2.6.4
CREATE TABLE tpce.commission_rate (
    cr_c_tier SMALLINT NOT NULL,
    cr_tt_id VARCHAR2(3) NOT NULL,
    cr_ex_id VARCHAR2(6) NOT NULL,
    cr_from_qty NUMBER(6) NOT NULL CHECK (cr_from_qty >= 0),
    cr_to_qty NUMBER(6) NOT NULL CHECK (cr_to_qty > 0),
    cr_rate NUMBER(5, 2) NOT NULL CHECK (cr_rate >= 0));

ALTER TABLE tpce.commission_rate ADD CONSTRAINT cr_to_qty_sup
    CHECK (cr_to_qty > cr_from_qty);
    

-- Clause 2.2.6.5
CREATE TABLE tpce.settlement (
    se_t_id NUMBER(15) NOT NULL,
    se_cash_type VARCHAR2(40) NOT NULL,
    se_cash_due_date DATE NOT NULL,
    se_amt NUMBER(10,2) NOT NULL);


-- Sequence for clause 2.2.6.6
CREATE SEQUENCE tpce.seq_trade_id
  MINVALUE 1
  START WITH 200000000000001
  INCREMENT BY 1
  CACHE 20;

-- Clause 2.2.6.6
CREATE TABLE tpce.trade (
    t_id NUMBER default seq_trade_id.nextval ,
    t_dts TIMESTAMP NOT NULL,
    t_st_id VARCHAR2(4) NOT NULL,
    t_tt_id VARCHAR2(3) NOT NULL,
    t_is_cash NUMBER(1,0) NOT NULL,
    t_s_symb VARCHAR2(15) NOT NULL,
    t_qty NUMBER(6) NOT NULL CHECK (t_qty > 0),
    t_bid_price NUMBER(8,2) NOT NULL CHECK (t_bid_price > 0),
    t_ca_id NUMBER(11) NOT NULL,
    t_exec_name VARCHAR2(64) NOT NULL,
    t_trade_price NUMBER(8,2),
    t_chrg NUMBER(10,2) NOT NULL CHECK (t_chrg >= 0),
    t_comm NUMBER(10,2) NOT NULL CHECK (t_comm >= 0),
    t_tax NUMBER(10,2) NOT NULL CHECK (t_tax >= 0),
    t_lifo NUMBER(1,0) NOT NULL);
    

-- Clause 2.2.6.7
CREATE TABLE tpce.trade_history (
    th_t_id NUMBER(15) NOT NULL,
    th_dts TIMESTAMP NOT NULL,
    th_st_id VARCHAR2(4) NOT NULL);
    

-- Clause 2.2.6.8
CREATE TABLE tpce.trade_request (
    tr_t_id NUMBER(15) NOT NULL,
    tr_tt_id VARCHAR2(3) NOT NULL,
    tr_s_symb VARCHAR2(15) NOT NULL,
    tr_qty NUMBER(6) NOT NULL CHECK (tr_qty > 0),
    tr_bid_price NUMBER(8,2) NOT NULL CHECK (tr_bid_price > 0),
    tr_b_id NUMBER(11) NOT NULL);
    

-- Clause 2.2.6.9
CREATE TABLE tpce.trade_type (
    tt_id VARCHAR2(3) NOT NULL,
    tt_name VARCHAR2(12) NOT NULL,
    tt_is_sell NUMBER(1,0) NOT NULL,
    tt_is_mrkt NUMBER(1,0) NOT NULL);
    

-- Market Tables

-- Clause 2.2.7.1
CREATE TABLE tpce.company (
    co_id NUMBER(11) NOT NULL,
    co_st_id VARCHAR2(4) NOT NULL,
    co_name VARCHAR2(60) NOT NULL,
    co_in_id VARCHAR2(2) NOT NULL,
    co_sp_rate VARCHAR2(4) NOT NULL,
    co_ceo VARCHAR2(100) NOT NULL,
    co_ad_id NUMBER(11) NOT NULL,
    co_desc VARCHAR2(150) NOT NULL,
    co_open_date DATE NOT NULL);
    

-- Clause 2.2.7.2
CREATE TABLE tpce.company_competitor (
    cp_co_id NUMBER(11) NOT NULL,
    cp_comp_co_id NUMBER(11) NOT NULL,
    cp_in_id VARCHAR2(2) NOT NULL);
    

-- Clause 2.2.7.3
CREATE TABLE tpce.daily_market (
    dm_date DATE NOT NULL,
    dm_s_symb VARCHAR2(15) NOT NULL,
    dm_close NUMBER(8,2) NOT NULL,
    dm_high NUMBER(8,2) NOT NULL,
    dm_low NUMBER(8,2) NOT NULL,
    dm_vol NUMBER(12) NOT NULL);
    

-- Clause 2.2.7.4
CREATE TABLE tpce.exchange (
    ex_id VARCHAR2(6) NOT NULL,
    ex_name VARCHAR2(100) NOT NULL,
    ex_num_symb INTEGER NOT NULL,
    ex_open INTEGER NOT NULL,
    ex_close INTEGER NOT NULL,
    ex_desc VARCHAR2(150),
    ex_ad_id NUMBER(11) NOT NULL);
    

-- Clause 2.2.7.5
CREATE TABLE tpce.financial (
    fi_co_id NUMBER(11) NOT NULL,
    fi_year INTEGER NOT NULL,
    fi_qtr SMALLINT NOT NULL,
    fi_qtr_start_date DATE NOT NULL,
    fi_revenue NUMBER(15,2) NOT NULL,
    fi_net_earn NUMBER(15,2) NOT NULL,
    fi_basic_eps NUMBER(10,2) NOT NULL,
    fi_dilut_eps NUMBER(10,2) NOT NULL,
    fi_margin NUMBER(10,2) NOT NULL,
    fi_inventory NUMBER(15,2) NOT NULL,
    fi_assets NUMBER(15,2) NOT NULL,
    fi_liability NUMBER(15,2) NOT NULL,
    fi_out_basic NUMBER(12) NOT NULL,
    fi_out_dilut NUMBER(12) NOT NULL);
    

-- Clause 2.2.7.6
CREATE TABLE tpce.industry (
    in_id VARCHAR2(2) NOT NULL,
    in_name VARCHAR2(50) NOT NULL,
    in_sc_id VARCHAR2(2) NOT NULL);
    

-- Clause 2.2.7.7
CREATE TABLE tpce.last_trade (
    lt_s_symb VARCHAR2(15) NOT NULL,
    lt_dts TIMESTAMP NOT NULL,
    lt_price NUMBER(8,2) NOT NULL,
    lt_open_price NUMBER(8,2) NOT NULL,
    lt_vol NUMBER(12));
    

-- Clause 2.2.7.8
-- FIXME: The NI_ITEM field may be either LOB(100000) or
--	LOB_Ref, which is a reference to a LOB(100000) object
--	stored outside the table. 
--	TEXT seems to be simpler to handle

CREATE TABLE tpce.news_item (
    ni_id NUMBER(11) NOT NULL,
    ni_headline VARCHAR2(80) NOT NULL,
    ni_summary VARCHAR2(255) NOT NULL,
    ni_item BLOB NOT NULL,
    ni_dts TIMESTAMP NOT NULL,
    ni_source VARCHAR2(30) NOT NULL,
    ni_author VARCHAR2(30));
    

-- Clause 2.2.7.9
CREATE TABLE tpce.news_xref (
    nx_ni_id NUMBER(11) NOT NULL,
    nx_co_id NUMBER(11) NOT NULL);
    

-- Clause 2.2.7.10
CREATE TABLE tpce.sector (
    sc_id VARCHAR2(2) NOT NULL,
    sc_name VARCHAR2(30) NOT NULL);
    

-- Clause 2.2.7.11
CREATE TABLE tpce.security (
    s_symb VARCHAR2(15) NOT NULL,
    s_issue VARCHAR2(6) NOT NULL,
    s_st_id VARCHAR2(4) NOT NULL,
    s_name VARCHAR2(70) NOT NULL,
    s_ex_id VARCHAR2(6) NOT NULL,
    s_co_id NUMBER(11) NOT NULL,
    s_num_out NUMBER(12) NOT NULL,
    s_start_date DATE NOT NULL,
    s_exch_date DATE NOT NULL,
    s_pe NUMBER(10,2) NOT NULL,
    s_52wk_high NUMBER(8,2) NOT NULL,
    s_52wk_high_date DATE NOT NULL,
    s_52wk_low NUMBER(8,2) NOT NULL,
    s_52wk_low_date DATE NOT NULL,
    s_dividend NUMBER(10,2) NOT NULL,
    s_yield NUMBER(5,2) NOT NULL);
    

-- Dimension Tables

-- Clause 2.2.8.1
CREATE TABLE tpce.address (
    ad_id NUMBER(11) NOT NULL,
    ad_line1 VARCHAR2(80),
    ad_line2 VARCHAR2(80),
    ad_zc_code VARCHAR2(12) NOT NULL,
    ad_ctry VARCHAR2(80));
    

-- Clause 2.2.8.2
CREATE TABLE tpce.status_type (
    st_id VARCHAR2(4) NOT NULL,
    st_name VARCHAR2(10) NOT NULL);
    

-- Clause 2.2.8.3
CREATE TABLE tpce.taxrate (
    tx_id VARCHAR2(4) NOT NULL,
    tx_name VARCHAR2(50) NOT NULL,
    tx_rate NUMBER(6,5) NOT NULL CHECK (tx_rate >= 0));
    

-- Clause 2.2.8.4
CREATE TABLE tpce.zip_code (
    zc_code VARCHAR2(12) NOT NULL,
    zc_town VARCHAR2(80) NOT NULL,
    zc_div VARCHAR2(80) NOT NULL);
    

exit 
