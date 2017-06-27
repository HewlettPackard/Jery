spool indexes_fk2.log

connect TPCE/TPCE
-- The FKs of each table are stored in the same tablespace
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

spool off
