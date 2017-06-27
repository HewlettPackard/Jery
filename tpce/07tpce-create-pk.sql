-- PKs
spool indexes.log

connect TPCE/TPCE

-- Clause 2.2.5.1
ALTER TABLE account_permission
ADD CONSTRAINT pk_account_permission
PRIMARY KEY (ap_ca_id, ap_tax_id);

-- Clause 2.2.5.2
ALTER TABLE customer
ADD CONSTRAINT pk_customer
PRIMARY KEY (c_id);

-- Clause 2.2.5.3
ALTER TABLE customer_account
ADD CONSTRAINT pk_customer_account
PRIMARY KEY (ca_id);

-- Clause 2.2.5.4
ALTER TABLE customer_taxrate
ADD CONSTRAINT pk_customer_taxrate
PRIMARY KEY (cx_tx_id, cx_c_id);

-- Clause 2.2.5.5
ALTER TABLE holding
ADD CONSTRAINT pk_holding
PRIMARY KEY (h_t_id);

-- Clause 2.2.5.6
ALTER TABLE holding_history
ADD CONSTRAINT pk_holding_history
PRIMARY KEY (hh_h_t_id, hh_t_id);

-- Clause 2.2.5.7
ALTER TABLE holding_summary
ADD CONSTRAINT pk_holding_summary
PRIMARY KEY (hs_ca_id, hs_s_symb);

-- Clause 2.2.5.8
ALTER TABLE watch_item
ADD CONSTRAINT pk_watch_item 
PRIMARY KEY (wi_wl_id, wi_s_symb);

-- Clause 2.2.5.9
ALTER TABLE watch_list
ADD CONSTRAINT pk_watch_list
PRIMARY KEY (wl_id);

-- Clause 2.2.6.1
ALTER TABLE broker
ADD CONSTRAINT pk_broker
PRIMARY KEY (b_id);

-- Clause 2.2.6.2
ALTER TABLE cash_transaction
ADD CONSTRAINT pk_cash_transaction
PRIMARY KEY (ct_t_id);

-- Clause 2.2.6.3
ALTER TABLE charge
ADD CONSTRAINT pk_charge 
PRIMARY KEY (ch_tt_id, ch_c_tier);

-- Clause 2.2.6.4
ALTER TABLE commission_rate
ADD CONSTRAINT pk_commission_rate 
PRIMARY KEY (cr_c_tier, cr_tt_id, cr_ex_id, cr_from_qty);

-- Clause 2.2.6.5
ALTER TABLE settlement
ADD CONSTRAINT pk_settlement PRIMARY KEY (se_t_id);

-- Clause 2.2.6.6
ALTER TABLE trade
ADD CONSTRAINT pk_trade PRIMARY KEY (t_id);

-- Clause 2.2.6.7
ALTER TABLE trade_history
ADD CONSTRAINT pk_trade_history
PRIMARY KEY (th_t_id, th_st_id);

-- Clause 2.2.6.8
ALTER TABLE trade_request
ADD CONSTRAINT pk_trade_request
PRIMARY KEY (tr_t_id);

-- Clause 2.2.6.9
ALTER TABLE trade_type
ADD CONSTRAINT pk_trade_type
PRIMARY KEY (tt_id);

-- Clause 2.2.7.1
ALTER TABLE company
ADD CONSTRAINT pk_company
PRIMARY KEY (co_id);

-- Clause 2.2.7.2
ALTER TABLE company_competitor
ADD CONSTRAINT pk_company_competitor 
PRIMARY KEY (cp_co_id, cp_comp_co_id, cp_in_id);

-- Clause 2.2.7.3
ALTER TABLE daily_market
ADD CONSTRAINT pk_daily_market
PRIMARY KEY (dm_date, dm_s_symb);

-- Clause 2.2.7.4
ALTER TABLE exchange
ADD CONSTRAINT pk_exchange
PRIMARY KEY (ex_id);

-- Clause 2.2.7.5
ALTER TABLE financial
ADD CONSTRAINT pk_financial
PRIMARY KEY (fi_co_id, fi_year, fi_qtr);

-- Clause 2.2.7.6
ALTER TABLE industry
ADD CONSTRAINT pk_industry
PRIMARY KEY (in_id);

-- Clause 2.2.7.7
ALTER TABLE last_trade
ADD CONSTRAINT pk_last_trade
PRIMARY KEY (lt_s_symb);

-- Clause 2.2.7.8
ALTER TABLE news_item
ADD CONSTRAINT pk_news_item
PRIMARY KEY (ni_id);

-- Clause 2.2.7.9
ALTER TABLE news_xref
ADD CONSTRAINT pk_news_xref
PRIMARY KEY (nx_ni_id, nx_co_id);

-- Clause 2.2.7.10
ALTER TABLE sector
ADD CONSTRAINT pk_sector
PRIMARY KEY (sc_id);

-- Clause 2.2.7.11
ALTER TABLE security
ADD CONSTRAINT pk_security
PRIMARY KEY (s_symb);

-- Clause 2.2.8.1
ALTER TABLE address
ADD CONSTRAINT pk_address
PRIMARY KEY (ad_id);

-- Clause 2.2.8.2
ALTER TABLE status_type
ADD CONSTRAINT pk_status_type
PRIMARY KEY (st_id);

-- Clause 2.2.8.3
ALTER TABLE taxrate
ADD CONSTRAINT pk_taxrate
PRIMARY KEY (tx_id);

-- Clause 2.2.8.4
ALTER TABLE zip_code
ADD CONSTRAINT pk_zip_code
PRIMARY KEY (zc_code);

