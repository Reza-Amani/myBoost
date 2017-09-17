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
   string report;
 public:
   TradeControl();
   bool buy(double _lots, double _sl, double _tp);
   bool sell(double _lots, double _sl, double _tp);
   bool edit_sl( double _sl);
   bool have_open_trade();
   bool is_buy_trade();
   bool close();
   string get_report();
   void clear_report();
   int open_ticket;
   
};
TradeControl::TradeControl():open_ticket(0),trade_id(0),report("")
{
}
bool TradeControl::buy(double _lots, double _sl, double _tp)
{
   if(have_open_trade())
      return false;  //return error, cause there is already a ticket opened by me
      
   open_ticket=OrderSend(Symbol(),OP_BUY, _lots, Ask, 0,_sl,_tp,"buy",++trade_id,0,clrAliceBlue); //returns ticket n assigned by server, or -1 for error
   if(open_ticket!=-1)
      return true;
   else
   {
      open_ticket = 0;
      return false;
   }
}
bool TradeControl::sell(double _lots, double _sl, double _tp)
{
   if(have_open_trade())
      return false;  //return error, cause there is already a ticket opened by me
      
   open_ticket=OrderSend(Symbol(),OP_SELL, _lots, Bid, 0,_sl,_tp,"sell",++trade_id,0,clrOrangeRed); //returns ticket n assigned by server, or -1 for error
   if(open_ticket!=-1)
      return true;
   else
   {
      open_ticket = 0;
      return false;
   }
}
bool TradeControl::have_open_trade()
{
   if(OrderSelect(open_ticket,SELECT_BY_TICKET)) 
   {
      if(OrderCloseTime()==0)
         return true;
      else
         return false;
   }
   else
      return false;
}
bool TradeControl::is_buy_trade()
{
   if(OrderSelect(open_ticket,SELECT_BY_TICKET)) 
      return (OrderType()==OP_BUY);
   else  //no open ticket
   {
      report+="error in selecting the ticket";
      return false;
   }
}
bool TradeControl::edit_sl( double _sl)
{
   if(OrderSelect(open_ticket,SELECT_BY_TICKET)) 
   {
      if(_sl==OrderStopLoss())   //no change in sl
         return false;
      if(OrderModify(open_ticket,OrderOpenPrice(),_sl,OrderTakeProfit(),0,clrAliceBlue))
         return true;
      else
      {   //error in modifying
         report+="error in modifying";
         return false;
      }
   }
   else  //no open ticket
   {
      report+="error in selecting the ticket";
      return false;
   }
}
bool TradeControl::close(void)
{
   if(OrderSelect(open_ticket,SELECT_BY_TICKET)) 
   {
      if(OrderClose(OrderTicket(),OrderLots(), (OrderType()==OP_BUY)?Bid:Ask,10,(OrderType()==OP_BUY)?clrBlue:clrOrange))
         return true;
      else
      {   //error in closing
         report+="error in closing the ticket";
         return false;
      }
   }
   else  //no open ticket
   {
      report+="error in selecting the ticket";
      return false;
   }
}
string TradeControl::get_report()
{
   return report;
}
void TradeControl::clear_report()
{
   report="";
}