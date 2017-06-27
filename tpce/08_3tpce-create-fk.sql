spool indexes_fk3.log

connect TPCE/TPCE
-- The FKs of each table are stored in the same tablespace

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

spool off
