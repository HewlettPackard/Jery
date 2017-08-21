
DROP FUNCTION BrokerVolumeFrame1 (
                in_broker_list IN B_NAME_ARRAY,
                in_sector_name IN VARCHAR2,
                broker_name OUT B_NAME_ARRAY ,
                list_len OUT INTEGER,
                status OUT INTEGER,
                volume OUT VOL_ARRAY);
				
DROP FUNCTION CustomerPositionFrame1 (
                cust_id IN OUT NUMBER,
                tax_id IN VARCHAR2,
                acct_id OUT ID_ARRAY,
                acct_len OUT INTEGER,
                asset_total OUT TOT_ARRAY,
                c_ad_id OUT NUMBER,
                c_area_1 OUT VARCHAR,
                c_area_2 OUT VARCHAR,
                c_area_3 OUT VARCHAR,
                c_ctry_1 OUT VARCHAR,
                c_ctry_2 OUT VARCHAR,
                c_ctry_3 OUT VARCHAR,
                c_dob OUT DATE,
                c_email_1 OUT VARCHAR2,
                c_email_2 OUT VARCHAR2,
                c_ext_1 OUT VARCHAR,
                c_ext_2 OUT VARCHAR,
                c_ext_3 OUT VARCHAR,
                c_f_name OUT VARCHAR2,
                c_gndr OUT VARCHAR,
                c_l_name OUT VARCHAR2,
                c_local_1 OUT VARCHAR,
                c_local_2 OUT VARCHAR,
                c_local_3 OUT VARCHAR,
                c_m_name OUT VARCHAR,
                c_st_id OUT VARCHAR,
                c_tier OUT NUMBER,
                cash_bal OUT TOT_ARRAY,
                status OUT INTEGER
                );


DROP FUNCTION CustomerPositionFrame2(
                acct_id IN NUMBER,
                hist_dts OUT C_TMPSTMP_ARRAY,
                hist_len OUT INTEGER,
                qty OUT C_NUM_ARRAY,
                status OUT INTEGER,
                symbol OUT C_NAME_ARRAY,
                trade_id OUT C_NUM_ARRAY,
                trade_status OUT C_NAME_ARRAY);
				
				
DROP FUNCTION DataMaintenanceFrame1 (
                in_acct_id IN NUMBER,
                in_c_id IN NUMBER,
                in_co_id IN NUMBER ,
                day_of_month IN INTEGER,
                symbol IN VARCHAR2,
                table_name IN VARCHAR2,
                in_tx_id IN VARCHAR2,
                vol_incr IN INTEGER,
                status OUT INTEGER);

				


DROP FUNCTION MarketFeedFrame1 (
                                        MaxSize         IN INTEGER,
                                        price_quote     IN      PR_ARRAY,
                                        status_submitted        IN VARCHAR2,
                                        symbol          IN SYM_ARRAY,
                                        trade_qty               IN TR_ARRAY,
                                        type_limit_buy  IN VARCHAR2,
                                        type_limit_sell IN VARCHAR2,
                                        type_stop_loss  IN VARCHAR2);
										

DROP FUNCTION MarketWatchFrame1 (
                                                acct_id         IN NUMBER,
                                                cust_id         IN NUMBER,
                                                ending_co_id IN NUMBER,
                                                industry_name IN VARCHAR2,
                                                starting_co_id  IN NUMBER);

DROP FUNCTION SecurityDetailFrame1 (
                                                access_lob_flag IN INTEGER,
                                                max_rows_to_return      IN INTEGER,
                                                start_day IN DATE,
                                                symbol  IN      VARCHAR2
                                                );

DROP FUNCTION TradeCleanupFrame1 (
                                                st_canceled_id  IN VARCHAR2,
                                                st_pending_id   IN VARCHAR2,
                                                st_submitted_id IN VARCHAR2,
                                                start_trade_id  IN NUMBER);
									

DROP FUNCTION TradeLookupFrame1(max_trades IN NUMBER, trade_id IN ARINT15 );

DROP FUNCTION TradeLookupFrame2(     acct_id IN NUMBER,      max_trades      IN integer,     trade_dts       IN timestamp);

DROP FUNCTION TradeLookupFrame3( max_acct_id IN NUMBER, max_trades IN INTEGER, TRADE_DTS in TIMESTAMP,SYMBOL IN VARCHAR2);

DROP FUNCTION TradeLookupFrame4(acct_id      IN NUMBER,trade_dts      IN timestamp);


DROP FUNCTION TradeOrderFrame1 (acct_id IN NUMBER);

DROP FUNCTION TradeOrderFrame2(acct_id IN NUMBER(11),
                                                 exec_f_name IN varchar2,
                                                 exec_l_name IN varchar2,
                                                 exec_tax_id IN varchar2);

DROP FUNCTION TradeOrderFrame3(
                                                acct_id IN NUMBER,
                                                cust_id  IN NUMBER,
                                                cust_tier IN NUMBER,
                                                is_lifo IN NUMBER,
                                                issue IN VARCHAR2,
                                                st_pending_id IN VARCHAR2,
                                                st_submitted_id IN VARCHAR2,
                                                tax_status      IN NUMBER,
                                                trade_qty       IN NUMBER,
                                                trade_type_id IN VARCHAR2,
                                                type_is_margin  IN NUMBER,
                                                company_name IN varchar2,
                                                requested_price IN NUMBER,
                                                symbol  IN VARCHAR2);

DROP FUNCTION TradeOrderFrame4(
                                 acct_id            IN NUMBER,
                                 charge_amount      IN NUMBER,
                             comm_amount        IN NUMBER,
                                 exec_name          IN VARCHAR2,
                                 is_cash            IN NUMBER,
                                 is_lifo            IN NUMBER,
                                 requested_price    IN NUMBER,
                                 status_id          IN VARCHAR2,
                                 symbol             IN VARCHAR2,
                                 trade_qty          IN VARCHAR2,
                                 trade_type_id      IN VARCHAR2,
                                 type_is_market     IN NUMBER);


DROP FUNCTION TradeResultFrame1 (trade_id IN NUMBER);


DROP FUNCTION TradeResultFrame2(
                                acct_id IN NUMBER,
                                holdsum_qty     IN NUMBER,
                                is_lifo IN INTEGER,
                                symbol IN VARCHAR2,
                                trade_id        IN NUMBER,
                                trade_price     IN NUMBER,
                                trade_qty       IN NUMBER,
                                type_is_sell    IN INTEGER);


DROP FUNCTION TradeResultFrame3(
                                buy_value       IN NUMBER,
                                cust_id IN NUMBER,
                                sell_value      IN NUMBER,
                                trade_id        IN NUMBER,
                                tax_amnt        IN NUMBER);


DROP FUNCTION TradeResultFrame4(
                                cust_id IN NUMBER,
                                symbol  IN VARCHAR2,
                                trade_qty       IN NUMBER,
                                type_id IN VARCHAR2);

DROP FUNCTION TradeResultFrame5(
                                broker_id       IN NUMBER,
                                comm_amount     IN NUMBER,
                                st_completed_id IN VARCHAR2,
                                trade_dts               IN timestamp,
                                trade_id                IN NUMBER,
                                trade_price             IN NUMBER);


DROP FUNCTION TradeResultFrame6(
                                acct_id         IN NUMBER ,
                                due_date                IN timestamp,
                                s_name          IN varchar2,
                                se_amount    IN NUMBER,
                                trade_dts       IN      timestamp,
                                trade_id                IN NUMBER,
                                trade_is_cash   IN INTEGER,
                                trade_qty               IN NUMBER,
                                type_name               IN VARCHAR2);

DROP FUNCTION TradeStatusFrame1 (acct_id IN NUMBER);

DROP FUNCTION TradeUpdateFrame1(max_trades IN NUMBER, max_updates IN NUMBER, trade_id IN ARINT15 );

DROP FUNCTION TradeUpdateFrame2(acct_id      IN NUMBER,      max_trades      IN integer,     max_updates IN integer,trade_dts        IN timestamp);

DROP FUNCTION TradeUpdateFrame3( max_acct_id IN NUMBER,
                            max_trades IN INTEGER,
                            max_updates     IN integer,
                            TRADE_DTS in TIMESTAMP,
                            SYMBOL IN VARCHAR2);

