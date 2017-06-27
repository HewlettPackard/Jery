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


-- FKs
-- The FKs of each table are stored in the same tablespace

-- Clause 2.2.5.1
ALTER TABLE account_permission
ADD CONSTRAINT fk_account_permission_ca FOREIGN KEY (ap_ca_id)
REFERENCES customer_account (ca_id);

-- Clause 2.2.5.2
ALTER TABLE customer
ADD CONSTRAINT fk_customer_st FOREIGN KEY (c_st_id) 
REFERENCES status_type (st_id);

ALTER TABLE customer
ADD CONSTRAINT fk_customer_ad FOREIGN KEY (c_ad_id) 
REFERENCES address (ad_id);

-- Clause 2.2.5.3
ALTER TABLE customer_account
ADD CONSTRAINT fk_customer_account_b FOREIGN KEY (ca_b_id) 
REFERENCES broker (b_id);

ALTER TABLE customer_account
ADD CONSTRAINT fk_customer_account_c FOREIGN KEY (ca_c_id) 
REFERENCES customer (c_id);

-- Clause 2.2.5.4
ALTER TABLE customer_taxrate
ADD CONSTRAINT fk_customer_taxrate_tx FOREIGN KEY (cx_tx_id) 
REFERENCES taxrate (tx_id);

ALTER TABLE customer_taxrate
ADD CONSTRAINT fk_customer_taxrate_c FOREIGN KEY (cx_c_id) 
REFERENCES customer (c_id);

-- Clause 2.2.5.5
ALTER TABLE holding
ADD CONSTRAINT fk_holding_t FOREIGN KEY (h_t_id) 
REFERENCES trade (t_id);

ALTER TABLE holding
ADD CONSTRAINT fk_holding_hs FOREIGN KEY (h_ca_id, h_s_symb) 
REFERENCES holding_summary (hs_ca_id, hs_s_symb);

-- Clause 2.2.5.6
-- FIXME: Should the next two foreign keys be a single definition?
ALTER TABLE holding_history
ADD CONSTRAINT fk_holding_history_t1 FOREIGN KEY (hh_h_t_id) 
REFERENCES trade (t_id);

ALTER TABLE holding_history
ADD CONSTRAINT fk_holding_history_t2 FOREIGN KEY (hh_t_id) 
REFERENCES trade (t_id);

-- Clause 2.2.5.7
ALTER TABLE holding_summary
ADD CONSTRAINT fk_holding_summary_ca FOREIGN KEY (hs_ca_id) 
REFERENCES customer_account (ca_id);

ALTER TABLE holding_summary
ADD CONSTRAINT fk_holding_summary_s FOREIGN KEY (hs_s_symb) 
REFERENCES security (s_symb);

-- Clause 2.2.5.8
ALTER TABLE watch_item
ADD CONSTRAINT fk_watch_item_wl FOREIGN KEY (wi_wl_id) 
REFERENCES watch_list (wl_id);

ALTER TABLE watch_item
ADD CONSTRAINT fk_watch_item_s FOREIGN KEY (wi_s_symb) 
REFERENCES security (s_symb);

-- Clause 2.2.5.9
ALTER TABLE watch_list
ADD CONSTRAINT fk_watch_list FOREIGN KEY (wl_c_id) 
REFERENCES customer (c_id);

-- Clause 2.2.6.1
ALTER TABLE broker
ADD CONSTRAINT fk_broker FOREIGN KEY (b_st_id) 
REFERENCES status_type (st_id);

-- Clause 2.2.6.2
ALTER TABLE cash_transaction
ADD CONSTRAINT fk_cash_transaction FOREIGN KEY (ct_t_id) 
REFERENCES trade (t_id);

-- Clause 2.2.6.3
ALTER TABLE charge
ADD CONSTRAINT fk_charge FOREIGN KEY (ch_tt_id) 
REFERENCES trade_type (tt_id);

-- Clause 2.2.6.4
ALTER TABLE commission_rate
ADD CONSTRAINT fk_commission_rate_tt FOREIGN KEY (cr_tt_id) 
REFERENCES trade_type (tt_id);

ALTER TABLE commission_rate
ADD CONSTRAINT fk_commission_rate_ex FOREIGN KEY (cr_ex_id) 
REFERENCES exchange (ex_id);

-- Clause 2.2.6.5
ALTER TABLE settlement
ADD CONSTRAINT fk_settlement FOREIGN KEY (se_t_id) 
REFERENCES trade (t_id);

-- Clause 2.2.6.6
ALTER TABLE trade
ADD CONSTRAINT fk_trade_st FOREIGN KEY (t_st_id) 
REFERENCES status_type (st_id);

ALTER TABLE trade
ADD CONSTRAINT fk_trade_tt FOREIGN KEY (t_tt_id) 
REFERENCES trade_type (tt_id);

ALTER TABLE trade
ADD CONSTRAINT fk_trade_s FOREIGN KEY (t_s_symb) 
REFERENCES security (s_symb);

ALTER TABLE trade
ADD CONSTRAINT fk_trade_ca FOREIGN KEY (t_ca_id) 
REFERENCES customer_account (ca_id);

-- Clause 2.2.6.7
ALTER TABLE trade_history
ADD CONSTRAINT fk_trade_history_t FOREIGN KEY (th_t_id) 
REFERENCES trade (t_id);

ALTER TABLE trade_history
ADD CONSTRAINT fk_trade_history_st FOREIGN KEY (th_st_id) 
REFERENCES status_type (st_id);

-- Clause 2.2.6.8
ALTER TABLE trade_request
ADD CONSTRAINT fk_trade_request_t FOREIGN KEY (tr_t_id) 
REFERENCES trade (t_id);

ALTER TABLE trade_request
ADD CONSTRAINT fk_trade_request_tt FOREIGN KEY (tr_tt_id) 
REFERENCES trade_type (tt_id);

ALTER TABLE trade_request
ADD CONSTRAINT fk_trade_request_s FOREIGN KEY (tr_s_symb) 
REFERENCES security (s_symb);

ALTER TABLE trade_request
ADD CONSTRAINT fk_trade_request_b FOREIGN KEY (tr_b_id) 
REFERENCES broker (b_id);

-- Clause 2.2.7.1
ALTER TABLE company
ADD CONSTRAINT fk_company_st FOREIGN KEY (co_st_id) 
REFERENCES status_type (st_id);

ALTER TABLE company
ADD CONSTRAINT fk_company_in FOREIGN KEY (co_in_id) 
REFERENCES industry (in_id);

ALTER TABLE company
ADD CONSTRAINT fk_company_ad FOREIGN KEY (co_ad_id) 
REFERENCES address (ad_id);

-- Clause 2.2.7.2
ALTER TABLE company_competitor
ADD CONSTRAINT fk_company_competitor_co FOREIGN KEY (cp_co_id) 
REFERENCES company (co_id);

ALTER TABLE company_competitor
ADD CONSTRAINT fk_company_competitor_co2 FOREIGN KEY (cp_comp_co_id) 
REFERENCES company (co_id);

ALTER TABLE company_competitor
ADD CONSTRAINT fk_company_competitor_in FOREIGN KEY (cp_in_id) 
REFERENCES industry (in_id);

-- Clause 2.2.7.3
ALTER TABLE daily_market
ADD CONSTRAINT fk_daily_market FOREIGN KEY (dm_s_symb) 
REFERENCES security (s_symb);

-- Clause 2.2.7.4
ALTER TABLE exchange
ADD CONSTRAINT fk_exchange FOREIGN KEY (ex_ad_id) 
REFERENCES address (ad_id);

-- Clause 2.2.7.5
ALTER TABLE financial
ADD CONSTRAINT fk_financial FOREIGN KEY (fi_co_id) 
REFERENCES company (co_id);

-- Clause 2.2.7.6
ALTER TABLE industry
ADD CONSTRAINT fk_industry FOREIGN KEY (in_sc_id) 
REFERENCES sector (sc_id);

-- Clause 2.2.7.7
ALTER TABLE last_trade
ADD CONSTRAINT fk_last_trade FOREIGN KEY (lt_s_symb) 
REFERENCES security (s_symb);

-- Clause 2.2.7.9
ALTER TABLE news_xref
ADD CONSTRAINT fk_news_xref_ni FOREIGN KEY (nx_ni_id) 
REFERENCES news_item (ni_id);

ALTER TABLE news_xref
ADD CONSTRAINT fk_news_xref_co FOREIGN KEY (nx_co_id) 
REFERENCES company (co_id);

-- Clause 2.2.7.11
ALTER TABLE security
ADD CONSTRAINT fk_security_st FOREIGN KEY (s_st_id) 
REFERENCES status_type (st_id);

ALTER TABLE security
ADD CONSTRAINT fk_security_ex FOREIGN KEY (s_ex_id) 
REFERENCES exchange (ex_id);

ALTER TABLE security
ADD CONSTRAINT fk_security_co FOREIGN KEY (s_co_id) 
REFERENCES company (co_id);

-- Clause 2.2.8.1
ALTER TABLE address
ADD CONSTRAINT fk_address FOREIGN KEY (ad_zc_code) 
REFERENCES zip_code (zc_code);

-- Additional indexes

CREATE INDEX i_c_tax_id
ON customer (c_tax_id);

CREATE INDEX i_ca_c_id
ON customer_account (ca_c_id);

CREATE INDEX i_wl_c_id
ON watch_list (wl_c_id);

CREATE INDEX i_dm_s_symb
ON daily_market (dm_s_symb);

CREATE INDEX i_tr_s_symb
ON trade_request (tr_s_symb);

CREATE INDEX i_t_st_id
ON trade (t_st_id);

CREATE INDEX i_t_ca_id
ON trade (t_ca_id);

CREATE INDEX i_t_s_symb
ON trade (t_s_symb);

CREATE INDEX i_co_name
ON company (co_name);

CREATE INDEX i_security
ON security (s_co_id, s_issue);

CREATE INDEX i_holding
ON holding (h_ca_id, h_s_symb);

CREATE INDEX i_hh_t_id
ON holding_history (hh_t_id);

spool off
