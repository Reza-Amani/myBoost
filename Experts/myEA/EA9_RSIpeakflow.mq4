//+------------------------------------------------------------------+
//|                                                 EA7_patterns.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      ""
#property version   "1.00"
#property strict

#include <MyHeaders\MyMath.mqh>
#include <MyHeaders\Screen.mqh>
#include <MyHeaders\Tools.mqh>
#include <MyHeaders\MoneyManagement.mqh>
#include <MyHeaders\StopLoss.mqh>
#include <MyHeaders\TradeControl.mqh>

enum SearchAlgo
{
   SEARCH_BLIND_BUY_AT_30,
   SEARCH_BUYSELL_Q,
   SEARCH_PEAK_FLOW,
   SEARCH_PEAK_AGGRESSIVE
};
enum CloseAlgo
{
   CLOSE_AGGRESSIVE,
   CLOSE_CONSERVATIVE,
   CLOSE_FLOW_CONSERVATIVE,
   CLOSE_FLOW_EARLY

};
///////////////////////////////inputs
input int      RSI_len=28;
input int      filter_len=50;
input SearchAlgo     search_algo=SEARCH_PEAK_AGGRESSIVE;
input CloseAlgo     close_algo=CLOSE_FLOW_CONSERVATIVE; 
input double   sl_SAR_step=0.02; 
input double   lots_base = 1;
//////////////////////////////parameters
int trade_id=0;
int state=0;
int trade_counter=0;
int open_ticket=0;
//////////////////////////////objects
Screen screen;
MyMath math;
MoneyManagement money(lots_base);
StopLoss stop_loss(sl_SAR_step, 0.2);
TradeControl trade();
//int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
//int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
int search()
{  //returns 1 if opens a trade to proceed to next state
   //0 if unsuccessful search

   double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,1); 
   double rsi2 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,2); 
   double rsi3 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,3); 
   double rsi4 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,4); 
   double buy_quality = iCustom(Symbol(), Period(),"myIndicators/swing_quality", RSI_len, 0,1);
   double sell_quality = iCustom(Symbol(), Period(),"myIndicators/swing_quality", RSI_len, 1,1); 
   double slow_total_quality = iCustom(Symbol(), Period(),"myIndicators/swing_quality", RSI_len, 3,1); 

   double peak_flow = iCustom(Symbol(), Period(),"myIndicators/RSIpeaksAve", RSI_len, filter_len, 3,1); 
   double valey_flow = iCustom(Symbol(), Period(),"myIndicators/RSIpeaksAve", RSI_len, filter_len, 4,1); 
      //RSI of median price on last bar
      //a little aggressive, and ignoring the new open price
      //TODO: maybe considering the new open price for extra caution
//   double new_open_rsi = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_OPEN ,0,0); 
      
//   screen.add_L2_comment(" rsi 00="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, 0, 0,0,0))+" 10="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, 1, 0,0,0))+" 20="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, 2, 0,0,0))+" 3="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, 3, 0,0,0)));
   screen.clear_L1_comment();
   screen.add_L1_comment(" rsi1 ="+DoubleToString(rsi1));
   screen.clear_L2_comment();
   screen.add_L2_comment(" buyQ ="+DoubleToString(buy_quality));
/*   screen.clear_L3_comment();
   screen.add_L3_comment("totalQ ="+DoubleToString(slow_total_quality));
   screen.clear_L4_comment();
   screen.add_L4_comment("peakF ="+DoubleToString(peak_flow));
   screen.clear_L5_comment();
   screen.add_L5_comment("valeyF ="+DoubleToString(valey_flow));
*/   
   bool officer_allows = true;
   int thresh_sell = 70;
   int thresh_buy = 30;
   
   double sl=stop_loss.get_sl();
   
   if(officer_allows)
   {
      open_ticket=0;
      switch(search_algo)
      {
         case SEARCH_BLIND_BUY_AT_30:
            if(rsi2<=thresh_buy && rsi1>=thresh_buy)
            {
               double tp=0;
               tp=100+buy_quality;
               double lots = lots_base;
               trade.buy(lots,sl,tp);
            }
            break;
         case SEARCH_BUYSELL_Q:
            if(rsi2<=thresh_buy && rsi1>=thresh_buy)
            {
               double tp=0;
               tp=100+buy_quality;
               double lots = lots_base;
               if(buy_quality>35)
                  lots *= 1;
               else if(buy_quality>18)
                  lots *= 0.1;
               else
                  lots *= 0.01;
               trade.buy(lots,sl,tp);
            }
            break;
         case SEARCH_PEAK_FLOW:
            thresh_buy=(int)valey_flow;
            thresh_sell=(int)peak_flow;
            if( peak_flow>=70 && rsi2<=thresh_buy && rsi1>=thresh_buy)
            {
               double tp=0;
               tp=100+buy_quality;
               double lots = lots_base;
               trade.buy(lots,sl,tp);
            }
            break;
         case SEARCH_PEAK_AGGRESSIVE:
            thresh_buy=(int)valey_flow;
            thresh_sell=(int)peak_flow;
            if( (peak_flow>=70 && rsi2<=thresh_buy && rsi1>=thresh_buy)
               ||(peak_flow>=70 && rsi2<=thresh_buy && rsi1>=10+math.min(rsi2,rsi3,rsi4)))
            {
               double tp=0;
               tp=100+buy_quality;
               double  equity=AccountEquity();
               double lots = money.get_lots(1,Ask,sl,equity);
               screen.clear_L4_comment();
               screen.add_L4_comment("lots="+DoubleToString(lots));
               if(lots<0.01)
                  screen.add_L4_comment("-----insufficient lots");
               else
                  trade.buy(lots,sl,tp);
            }
            break;
      }
      
      if(open_ticket==-1)
      {
         screen.add_L3_comment("error in sending trade");
         return 0;
      }
      else if(open_ticket!=0  )
      {
         screen.add_L3_comment("trade placed");
         return 1;
      }
   }
   else
   {
      screen.clear_L2_comment();
      screen.add_L2_comment("officer not allowed");
   }
   return 0;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
int handle()
{  //returns 1 if closes the trade to return to base state
   //0 if the position remains still
   int return_closed=0;

   double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,1); 
   double rsi2 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,2); 
   double rsi3 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,3); 
   double rsi4 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,4); 
//   double new_open_rsi = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_OPEN ,0,0); 

   double peak_flow = iCustom(Symbol(), Period(),"myIndicators/RSIpeaksAve", RSI_len, filter_len, 3,1); 
   double valey_flow = iCustom(Symbol(), Period(),"myIndicators/RSIpeaksAve", RSI_len, filter_len, 4,1); 

   if(OrderSelect(open_ticket,SELECT_BY_TICKET)) 
   {
      int order_type=OrderType();
      if(order_type!=OP_BUY && order_type!=OP_SELL)
      {  //unexpected order type
         screen.clear_L3_comment();
         screen.add_L3_comment("unexpected order type");
         Print("unexpected order type");
         return 0;
      }
      double max=math.max(rsi2,rsi3,rsi4);
      switch(close_algo)
      {
         case CLOSE_AGGRESSIVE:
            if(rsi3>70 && rsi1<rsi2 && rsi1<rsi3)
               return_closed = close_order(open_ticket);
            else if(rsi2>80 && rsi1<rsi2)
               return_closed = close_order(open_ticket);
            else if(rsi3<=70 && rsi1<rsi2 && rsi1<rsi3-15)
               return_closed = close_order(open_ticket);
            else if(rsi4<=70 && rsi1<=rsi2 && rsi2<=rsi3 && rsi3<=rsi4)
               return_closed = close_order(open_ticket);
            else if(rsi1<30 && rsi2>=30)
               return_closed = close_order(open_ticket);
            break;
         case CLOSE_CONSERVATIVE:
            if(rsi1<=rsi2 && rsi2<=rsi3)
               return_closed = close_order(open_ticket);
            break;
         case CLOSE_FLOW_CONSERVATIVE:
            if(rsi1<=rsi2 && rsi1<=rsi3-15)
               return_closed = close_order(open_ticket);
            else if(rsi1<=peak_flow && rsi2>=peak_flow)
               return_closed = close_order(open_ticket);
            break;
         case CLOSE_FLOW_EARLY:
            if(rsi1<=peak_flow && rsi2>=peak_flow)
               return_closed = close_order(open_ticket);
            else if(max>peak_flow && rsi1<=max-5)
               return_closed = close_order(open_ticket);
            else if(rsi1<=max-10)
               return_closed = close_order(open_ticket);
            else if(max==99 && rsi1<99)
               return_closed = close_order(open_ticket);
            break;
      }
   }
   else
   {  //error in selecting the ticket
     //error in closing
      screen.clear_L3_comment();
      screen.add_L3_comment("error in selecting the ticket");
      Print("error in selecting the ticket");
   }
   return return_closed;

}
///////////////////////////////////////////////////
int close_order(int ticket)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET)) 
   {
      if(OrderClose(OrderTicket(),OrderLots(), (OrderType()==OP_BUY)?Bid:Ask,10,(OrderType()==OP_BUY)?clrBlue:clrOrange))
         return 1;
      else
      {   //error in closing
         screen.clear_L5_comment();
         screen.add_L5_comment("error in closing the ticket");
         Print("error in closing the ticket");
         return 0;
      }
   }
   screen.clear_L5_comment();
   screen.add_L5_comment("error in selecting the ticket");
   Print("error in selecting the ticket");
   return 0;

}
//+------------------------------------------------------------------+
//| standard function                                                |
//+------------------------------------------------------------------+
int OnInit()
{
   screen.add_L1_comment("EA started-");
/*   if(file<0 || outfilehandle<0)
   {
      screen.add_L1_comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return(INIT_FAILED);
   }
   screen.add_L1_comment("file ok-");
*/   return(INIT_SUCCEEDED);
}
double OnTester()
{
   return trade_counter;
}
void OnDeinit(const int reason)
{
//   FileWrite(file,"processed bars:", processed_bars," trade cnt", trade_counter);
}
void OnTick()
{
   if(IsTradeAllowed()==false)
      return;
   //just wait for new bar
   static datetime Time0=0;
   if (Time0 == Time[0])
   {  //check for RSI-based sl/tp during the bar here
      return;
   }
   else
   {  //new bar; main process
      Time0 = Time[0];
      screen.clear_L3_comment();
      
      switch(state)
      {
         case 0:
            if(search())  //chasing opurtunities and open trade if there is a valuable match
               state=1;
            break;
         case 1:
            if(handle())   //at the end of the first bar, probably close it
               state=0;
            break;
      }
   }
}
//+------------------------------------------------------------------+
