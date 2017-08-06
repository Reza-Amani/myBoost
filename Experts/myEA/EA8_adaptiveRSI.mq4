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

///////////////////////////////inputs
input bool     use_tp=true; 
//////////////////////////////parameters
int trade_id=0;
int state=0;
int trade_counter=0;
int open_ticket=0;
//////////////////////////////objects
Screen screen;
//int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
//int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
int search()
{  //returns 1 if opens a trade to proceed to next state
   //0 if unsuccessful search

   double rsi = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", 14, MODE_SMMA, PRICE_MEDIAN ,0,1); 
      //RSI of median price on last bar
      //a little aggressive, and ignoring the new open price
      //TODO: maybe considering the new open price for extra caution
      
   screen.clear_L2_comment();
//   screen.add_L2_comment(" rsi 00="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", 14, 0, 0,0,0))+" 10="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", 14, 1, 0,0,0))+" 20="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", 14, 2, 0,0,0))+" 3="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", 14, 3, 0,0,0)));
   screen.add_L2_comment(" rsi ="+DoubleToString(rsi));
   if(/*officer allows &&*/0)
   {  //a famous and good bar!
/*      trade_counter++;
      if(p_bar.direction==1)
      {
         double tp=0,sl=0;
         if(use_tp)
            tp=p_bar.pattern.close[0]+(tp_factor*p_bar.ave_aH1)*p_bar.pattern.absolute_diffs;
         if(use_sl)
            sl=p_bar.pattern.close[0]+(sl_factor*p_bar.ave_aL1)*p_bar.pattern.absolute_diffs;
         open_ticket=OrderSend(Symbol(),OP_BUY, i_Lots, Ask, 0,sl,tp,NULL,++trade_id,0,clrAliceBlue); //returns ticket n assigned by server, or -1 for error
      }
      else if(p_bar.direction==-1)
      {
         double tp=0,sl=0;
         if(use_tp)
            tp=p_bar.pattern.close[0]+(tp_factor*p_bar.ave_aL1)*p_bar.pattern.absolute_diffs;
         if(use_sl)
            sl=p_bar.pattern.close[0]+(sl_factor*p_bar.ave_aH1)*p_bar.pattern.absolute_diffs;
         open_ticket=OrderSend(Symbol(),OP_SELL, i_Lots, Bid, 0, sl,tp,NULL,++trade_id,0,clrAliceBlue);
      }
      screen.clear_L2_comment();
      screen.add_L2_comment("tradecnt:"+IntegerToString(trade_counter));
      screen.clear_L3_comment();
      if(open_ticket==-1)
      {
         screen.add_L3_comment("error in sending trade");
         return 0;
      }
      else
      {
         screen.add_L3_comment("trade placed");
         return 1;
      }
*/   }
   return 0;
}
int handle()
{  //returns 1 if closes the trade to return to base state
   //0 if remains here
   if(OrderSelect(open_ticket,SELECT_BY_TICKET)) 
      if(OrderClose(OrderTicket(),OrderLots(), (OrderType()==OP_BUY)?Bid:Ask,10))
         return 1;

  //error in closing
   screen.clear_L3_comment();
   screen.add_L3_comment("error in CLOSING");
   Print("error in closing");
   return 1;
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
