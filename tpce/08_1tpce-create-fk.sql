-- PKs
spool indexes_fk1.log

connect TPCE/TPCE

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

spool off
