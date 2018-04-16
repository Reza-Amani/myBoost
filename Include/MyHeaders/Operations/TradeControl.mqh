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
   bool ECN_account;
 public:
   TradeControl(bool _ECN_account);
   bool buy(double _lots, double _sl, double _tp);
   bool buy_if_no_trade(double _lots, double _sl, double _tp, bool _keep_losing_position);
   bool sell(double _lots, double _sl, double _tp);
   bool sell_if_no_trade(double _lots, double _sl, double _tp, bool _keep_losing_position);
   bool edit_sl( double _sl);
   bool edit_tp( double _tp);
   bool have_open_trade();
   bool is_in_profit();
   bool is_buy_trade();
   bool close();
   string get_report();
   void clear_report();
   int open_ticket;
   
};
TradeControl::TradeControl(bool _ECN_account):ECN_account(_ECN_account),open_ticket(0),trade_id(0),report("")
{
}
bool TradeControl::buy_if_no_trade(double _lots, double _sl, double _tp, bool _keep_losing_position)
{
   if(!have_open_trade())
      return buy(_lots,_sl,_tp);  //simply buy, if no trade is there
   else
      if(is_buy_trade())
      {  // if there was a compatible position
         if(_keep_losing_position || is_in_profit())
         {  //either keeping losing position is allowed or the position is profittable
            edit_sl(_sl);     //just update sl and tp
            edit_tp(_tp);
            return false;
         }
         else
         {
            close();
            return false;
         }
      }
      else
      {
         close();
         return buy(_lots,_sl,_tp);  //if the existing position was in the opposit way, close and open a new one
      }
}
bool TradeControl::sell_if_no_trade(double _lots, double _sl, double _tp, bool _keep_losing_position)
{
   if(!have_open_trade())
      return sell(_lots,_sl,_tp);  //simply sell, if no trade is there
   else
      if(!is_buy_trade())
      {  // if there was a compatible position
         if(_keep_losing_position || is_in_profit())
         {  //either keeping losing position is allowed or the position is profittable
            edit_sl(_sl);     //just update sl and tp
            edit_tp(_tp);
            return false;
         }
         else
         {
            close();
            return false;
         }
      }
      else
      {
         close();
         return sell(_lots,_sl,_tp);  //if the existing position was in the opposit way, close and open a new one
      }
}
bool TradeControl::buy(double _lots, double _sl, double _tp)
{
   if(have_open_trade())
      return false;  //return error, cause there is already a ticket opened by me
   
   if(!ECN_account)   
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
   else
   {
      open_ticket=OrderSend(Symbol(),OP_BUY, _lots, Ask, 0,0,0,"buy",++trade_id,0,clrAliceBlue); //in ECN acounts you have to open the order first and then set the sl and tp
      if(open_ticket==-1)
      {
         open_ticket = 0;
         return false;
      }
      else
      {
         edit_sl(_sl);
         edit_tp(_tp);
         return true;
      }
   }
}
bool TradeControl::sell(double _lots, double _sl, double _tp)
{
   if(have_open_trade())
      return false;  //return error, cause there is already a ticket opened by me
      
   if(!ECN_account)   
   {
      open_ticket=OrderSend(Symbol(),OP_SELL, _lots, Bid, 0,_sl,_tp,"sell",++trade_id,0,clrOrangeRed); //returns ticket n assigned by server, or -1 for error
      report+="opening the ticket. ";
      if(open_ticket!=-1)
         return true;
      else
      {
         open_ticket = 0;
         report+="error in opening the ticket ";
         return false;
      }
   }
   else
   {
      open_ticket=OrderSend(Symbol(),OP_SELL, _lots, Bid, 0,0,0,"sell",++trade_id,0,clrOrangeRed); //in ECN acounts you have to open the order first and then set the sl and tp
      report+="opening the ECN ticket. ";
      if(open_ticket==-1)
      {
         open_ticket = 0;
         report+="error in opening the ticket ";
         return false;
      }
      else
      {
         report+="sl/tp... ";
         edit_sl(_sl);
         edit_tp(_tp);
         return true;
      }
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
bool TradeControl::is_in_profit()
{
   if(OrderSelect(open_ticket,SELECT_BY_TICKET)) 
      return (OrderProfit()>0);
   else  //no open ticket
   {
      report+="error in selecting the ticket p";
      return false;
   }
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
bool TradeControl::edit_tp( double _tp)
{
   if(OrderSelect(open_ticket,SELECT_BY_TICKET)) 
   {
      if(_tp==OrderTakeProfit())   //no change in tp
         return false;
      if(OrderModify(open_ticket,OrderOpenPrice(),OrderStopLoss(),_tp,0,clrAliceBlue))
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
