spool indexes_fk4.log

connect TPCE/TPCE
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
