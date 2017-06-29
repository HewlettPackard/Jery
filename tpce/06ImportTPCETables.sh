#!/bin/bash
. ~/.profile
. ~/.bash_profile

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/AccountPermission.ctl log=/tmp/jery/scripts/AccountPermission.log bad=/tmp/jery/scripts/AccountPermission.bad discard=/tmp/jery/scripts/AccountPermission.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Address.ctl log=/tmp/jery/scripts/Address.log bad=/tmp/jery/scripts/Address.bad discard=/tmp/jery/scripts/Address.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Broker.ctl log=/tmp/jery/scripts/Broker.log bad=/tmp/jery/scripts/Broker.bad discard=/tmp/jery/scripts/Broker.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/CashTransaction.ctl log=/tmp/jery/scripts/CashTransaction.log bad=/tmp/jery/scripts/CashTransaction.bad discard=/tmp/jery/scripts/CashTransaction.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Charge.ctl log=/tmp/jery/scripts/Charge.log bad=/tmp/jery/scripts/Charge.bad discard=/tmp/jery/scripts/Charge.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/CommissionRate.ctl log=/tmp/jery/scripts/CommissionRate.log bad=/tmp/jery/scripts/CommissionRate.bad discard=/tmp/jery/scripts/CommissionRate.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Company.ctl log=/tmp/jery/scripts/Company.log bad=/tmp/jery/scripts/Company.bad discard=/tmp/jery/scripts/Company.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/CompanyCompetitor.ctl log=/tmp/jery/scripts/CompanyCompetitor.log bad=/tmp/jery/scripts/CompanyCompetitor.bad discard=/tmp/jery/scripts/CompanyCompetitor.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Customer.ctl log=/tmp/jery/scripts/Customer.log bad=/tmp/jery/scripts/Customer.bad discard=/tmp/jery/scripts/Customer.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/CustomerAccount.ctl log=/tmp/jery/scripts/CustomerAccount.log bad=/tmp/jery/scripts/CustomerAccount.bad discard=/tmp/jery/scripts/CustomerAccount.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/CustomerTaxrate.ctl log=/tmp/jery/scripts/CustomerTaxrate.log bad=/tmp/jery/scripts/CustomerTaxrate.bad discard=/tmp/jery/scripts/CustomerTaxrate.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/DailyMarket.ctl log=/tmp/jery/scripts/DailyMarket.log bad=/tmp/jery/scripts/DailyMarket.bad discard=/tmp/jery/scripts/DailyMarket.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Exchange.ctl log=/tmp/jery/scripts/Exchange.log bad=/tmp/jery/scripts/Exchange.bad discard=/tmp/jery/scripts/Exchange.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Financial.ctl log=/tmp/jery/scripts/Financial.log bad=/tmp/jery/scripts/Financial.bad discard=/tmp/jery/scripts/Financial.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Holding.ctl log=/tmp/jery/scripts/Holding.log bad=/tmp/jery/scripts/Holding.bad discard=/tmp/jery/scripts/Holding.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/HoldingHistory.ctl log=/tmp/jery/scripts/HoldingHistory.log bad=/tmp/jery/scripts/HoldingHistory.bad discard=/tmp/jery/scripts/HoldingHistory.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/HoldingSummary.ctl log=/tmp/jery/scripts/HoldingSummary.log bad=/tmp/jery/scripts/HoldingSummary.bad discard=/tmp/jery/scripts/HoldingSummary.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Industry.ctl log=/tmp/jery/scripts/Industry.log bad=/tmp/jery/scripts/Industry.bad discard=/tmp/jery/scripts/Industry.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/LastTrade.ctl log=/tmp/jery/scripts/LastTrade.log bad=/tmp/jery/scripts/LastTrade.bad discard=/tmp/jery/scripts/LastTrade.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/NewsItem.ctl log=/tmp/jery/scripts/NewsItem.log bad=/tmp/jery/scripts/NewsItem.bad discard=/tmp/jery/scripts/NewsItem.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/NewsXRef.ctl log=/tmp/jery/scripts/NewsXRef.log bad=/tmp/jery/scripts/NewsXRef.bad discard=/tmp/jery/scripts/NewsXRef.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Sector.ctl log=/tmp/jery/scripts/Sector.log bad=/tmp/jery/scripts/Sector.bad discard=/tmp/jery/scripts/Sector.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Security.ctl log=/tmp/jery/scripts/Security.log bad=/tmp/jery/scripts/Security.bad discard=/tmp/jery/scripts/Security.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Settlement.ctl log=/tmp/jery/scripts/Settlement.log bad=/tmp/jery/scripts/Settlement.bad discard=/tmp/jery/scripts/Settlement.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/StatusType.ctl log=/tmp/jery/scripts/StatusType.log bad=/tmp/jery/scripts/StatusType.bad discard=/tmp/jery/scripts/StatusType.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/TaxRate.ctl log=/tmp/jery/scripts/TaxRate.log bad=/tmp/jery/scripts/TaxRate.bad discard=/tmp/jery/scripts/TaxRate.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/Trade.ctl log=/tmp/jery/scripts/Trade.log bad=/tmp/jery/scripts/Trade.bad discard=/tmp/jery/scripts/Trade.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/TradeHistory.ctl log=/tmp/jery/scripts/TradeHistory.log bad=/tmp/jery/scripts/TradeHistory.bad discard=/tmp/jery/scripts/TradeHistory.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/TradeType.ctl log=/tmp/jery/scripts/TradeType.log bad=/tmp/jery/scripts/TradeType.bad discard=/tmp/jery/scripts/TradeType.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/WatchItem.ctl log=/tmp/jery/scripts/WatchItem.log bad=/tmp/jery/scripts/WatchItem.bad discard=/tmp/jery/scripts/WatchItem.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/WatchList.ctl log=/tmp/jery/scripts/WatchList.log bad=/tmp/jery/scripts/WatchList.bad discard=/tmp/jery/scripts/WatchList.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=/tmp/jery/scripts/ZipCode.ctl log=/tmp/jery/scripts/ZipCode.log bad=/tmp/jery/scripts/ZipCode.bad discard=/tmp/jery/scripts/ZipCode.discard direct=y errors=0 &
