#!/bin/bash

sqlldr userid=TPCE/TPCE control=AccountPermission.ctl log=AccountPermission.log bad=AccountPermission.bad discard=AccountPermission.discard direct=y errors=0 & 

sqlldr userid=TPCE/TPCE control=Address.ctl log=Address.log bad=Address.bad discard=Address.discard direct=y errors=0 & 

sqlldr userid=TPCE/TPCE control=Broker.ctl log=Broker.log bad=Broker.bad discard=Broker.discard direct=y errors=0 & 

sqlldr userid=TPCE/TPCE control=CashTransaction.ctl log=CashTransaction.log bad=CashTransaction.bad discard=CashTransaction.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Charge.ctl log=Charge.log bad=Charge.bad discard=Charge.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=CommissionRate.ctl log=CommissionRate.log bad=CommissionRate.bad discard=CommissionRate.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Company.ctl log=Company.log bad=Company.bad discard=Company.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=CompanyCompetitor.ctl log=CompanyCompetitor.log bad=CompanyCompetitor.bad discard=CompanyCompetitor.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Customer.ctl log=Customer.log bad=Customer.bad discard=Customer.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=CustomerAccount.ctl log=CustomerAccount.log bad=CustomerAccount.bad discard=CustomerAccount.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=CustomerTaxrate.ctl log=CustomerTaxrate.log bad=CustomerTaxrate.bad discard=CustomerTaxrate.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=DailyMarket.ctl log=DailyMarket.log bad=DailyMarket.bad discard=DailyMarket.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Exchange.ctl log=Exchange.log bad=Exchange.bad discard=Exchange.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Financial.ctl log=Financial.log bad=Financial.bad discard=Financial.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Holding.ctl log=Holding.log bad=Holding.bad discard=Holding.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=HoldingHistory.ctl log=HoldingHistory.log bad=HoldingHistory.bad discard=HoldingHistory.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=HoldingSummary.ctl log=HoldingSummary.log bad=HoldingSummary.bad discard=HoldingSummary.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Industry.ctl log=Industry.log bad=Industry.bad discard=Industry.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=LastTrade.ctl log=LastTrade.log bad=LastTrade.bad discard=LastTrade.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=NewsItem.ctl log=NewsItem.log bad=NewsItem.bad discard=NewsItem.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=NewsXRef.ctl log=NewsXRef.log bad=NewsXRef.bad discard=NewsXRef.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Sector.ctl log=Sector.log bad=Sector.bad discard=Sector.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Security.ctl log=Security.log bad=Security.bad discard=Security.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Settlement.ctl log=Settlement.log bad=Settlement.bad discard=Settlement.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=StatusType.ctl log=StatusType.log bad=StatusType.bad discard=StatusType.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=TaxRate.ctl log=TaxRate.log bad=TaxRate.bad discard=TaxRate.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=Trade.ctl log=Trade.log bad=Trade.bad discard=Trade.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=TradeHistory.ctl log=TradeHistory.log bad=TradeHistory.bad discard=TradeHistory.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=TradeType.ctl log=TradeType.log bad=TradeType.bad discard=TradeType.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=WatchItem.ctl log=WatchItem.log bad=WatchItem.bad discard=WatchItem.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=WatchList.ctl log=WatchList.log bad=WatchList.bad discard=WatchList.discard direct=y errors=0 &

sqlldr userid=TPCE/TPCE control=ZipCode.ctl log=ZipCode.log bad=ZipCode.bad discard=ZipCode.discard direct=y errors=0 &
