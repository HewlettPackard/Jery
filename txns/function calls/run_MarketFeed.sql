CONNECT TPCE/TPCE
SET SERVEROUTPUT ON;
DECLARE
    MaxSize INTEGER;
    status_submitted VARCHAR2(50);
    type_limit_buy	VARCHAR2(50);
    type_limit_sell	VARCHAR2(50);
    type_stop_loss	VARCHAR2(50);
    
    price_quote	TPCE.MARKETFEEDFRAME1_PKG.PR_ARRAY := TPCE.MARKETFEEDFRAME1_PKG.PR_ARRAY();
    symbol TPCE.MARKETFEEDFRAME1_PKG.SYM_ARRAY := TPCE.MARKETFEEDFRAME1_PKG.SYM_ARRAY();
    trade_qty TPCE.MARKETFEEDFRAME1_PKG.TR_ARRAY := TPCE.MARKETFEEDFRAME1_PKG.TR_ARRAY();
    
    lowerBound INTEGER;
    upperBound INTEGER;
    
    marketFeedFrame1_tbl  MarketFeedFrame1_Pkg.MarketFeedFrame1_tab := MarketFeedFrame1_Pkg.MarketFeedFrame1_tab();
    marketFeedFrame1rec MarketFeedFrame1_Pkg.MarketFeedFrame1_record ;
    
BEGIN
MaxSize := 2;
status_submitted := 'CMPT';
select tr_tt_id into type_limit_buy from ( select tr_tt_id, row_number() over (order by tr_tt_id) rno from trade_request order by rno) where  rno = ( select round (dbms_random.value (1,2)) from dual);
select tr_tt_id into type_limit_sell from ( select tr_tt_id, row_number() over (order by tr_tt_id) rno from trade_request order by rno) where  rno = ( select round (dbms_random.value (1,2)) from dual);
select tr_tt_id into type_stop_loss from ( select tr_tt_id, row_number() over (order by tr_tt_id) rno from trade_request order by rno) where  rno = ( select round (dbms_random.value (1,2)) from dual);

lowerbound := 0;
upperbound := 3;

SELECT tr_bid_price BULK COLLECT INTO price_quote FROM ( SELECT tr_bid_price , row_number() over (order by tr_bid_price) rno FROM trade_request )
                            WHERE  rno < upperBound 
                            AND rno > lowerBound;
SELECT tr_s_symb BULK COLLECT INTO symbol FROM ( SELECT tr_s_symb , row_number() over (order by tr_s_symb) rno FROM trade_request )
                            WHERE  rno < upperBound 
                            AND rno > lowerBound;
SELECT lt_vol BULK COLLECT INTO trade_qty FROM ( SELECT lt_vol , row_number() over (order by lt_vol) rno FROM last_trade )
                            WHERE  rno < upperBound 
                            AND rno > lowerBound;

-- DEBUGGING
dbms_output.put_line('MaxSize:           ' || MaxSize);
dbms_output.put_line('status_submitted:  ' || status_submitted);
dbms_output.put_line('type_limit_buy:    ' || type_limit_buy);
dbms_output.put_line('type_limit_sell:   ' || type_limit_sell);
dbms_output.put_line('type_stop_loss:    ' || type_stop_loss);
dbms_output.put_line('lowerBound:        ' || lowerBound);
dbms_output.put_line('upperBound:        ' || upperBound);

marketFeedFrame1_tbl := MarketFeedFrame1_Pkg.MarketFeedFrame1(MaxSize, price_quote, status_submitted, symbol, trade_qty, type_limit_buy, type_limit_sell, type_stop_loss);

END;
/