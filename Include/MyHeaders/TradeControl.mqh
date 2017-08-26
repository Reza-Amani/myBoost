//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
class TradeControl
{
   int trade_id;
 public:
   TradeControl();
   bool buy(double _lots, double _sl, double _tp);
   
   int open_ticket;
   
};
TradeControl::TradeControl():open_ticket(0),trade_id(0)
{
}
bool TradeControl::buy(double _lots, double _sl, double _tp)
{
   open_ticket=OrderSend(Symbol(),OP_BUY, _lots, Ask, 0,_sl,_tp,"buy",++trade_id,0,clrAliceBlue); //returns ticket n assigned by server, or -1 for error
   if(open_ticket!=-1)
      return true;
   else
   {
      open_ticket = 0;
      return false;
   }
}
