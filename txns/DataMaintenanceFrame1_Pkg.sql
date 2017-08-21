create or replace PACKAGE DataMaintenanceFrame1_Pkg AS
FUNCTION DataMaintenanceFrame1 (
		in_acct_id IN NUMBER,
		in_c_id IN NUMBER,
		in_co_id IN NUMBER ,
		day_of_month IN INTEGER,
		symbol IN VARCHAR2,
		table_name IN VARCHAR2,
		in_tx_id IN VARCHAR2,
		vol_incr IN INTEGER,
		status OUT INTEGER)
RETURN INTEGER;
 
FUNCTION SWF_OVERLAY(p_source VARCHAR2, p_replace VARCHAR2, p_start NUMBER, p_len NUMBER)
RETURN VARCHAR2;

END DataMaintenanceFrame1_Pkg;
