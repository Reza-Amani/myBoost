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
input int RSI_len=14;
input bool     use_tp=true; 
input double i_Lots = 0.1;
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

//   double rsi1 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,1); 
   double rsi1 = iCustom(Symbol(), Period(),"myIndicators/swing_quality", 1,1); 
   double rsi2 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,2); 
      //RSI of median price on last bar
      //a little aggressive, and ignoring the new open price
      //TODO: maybe considering the new open price for extra caution
//   double new_open_rsi = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_OPEN ,0,0); 
      
   screen.clear_L2_comment();
//   screen.add_L2_comment(" rsi 00="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, 0, 0,0,0))+" 10="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, 1, 0,0,0))+" 20="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, 2, 0,0,0))+" 3="+DoubleToString(iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, 3, 0,0,0)));
   screen.add_L2_comment(" rsi ="+DoubleToString(rsi1));
   
   bool officer_allows = true;
   int thresh_over_bought = 70;
   int thresh_over_sold = 30;
   
   if(officer_allows)
   {
      open_ticket=0;
      if(rsi2>=thresh_over_bought && rsi1<=thresh_over_bought)
      {
         double tp=0,sl=0;
//         if(use_tp)
//            tp=;
//         if(use_sl)
//            sl=s;
         open_ticket=OrderSend(Symbol(),OP_SELL, i_Lots, Bid, 0, sl,tp,"sell",++trade_id,0,clrRed);
      }
      else if(rsi2<=thresh_over_sold && rsi1>=thresh_over_sold)
      {
         double tp=0,sl=0;
//         if(use_tp)
//            tp=;
//         if(use_sl)
//            sl=s;
         open_ticket=OrderSend(Symbol(),OP_BUY, i_Lots, Ask, 0,sl,tp,"buy",++trade_id,0,clrAliceBlue); //returns ticket n assigned by server, or -1 for error
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
int close_order(int ticket)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET)) 
   {
      if(OrderClose(OrderTicket(),OrderLots(), (OrderType()==OP_BUY)?Bid:Ask,10,(OrderType()==OP_BUY)?clrBlue:clrOrange))
         return 1;
      else
      {   //error in closing
         screen.clear_L3_comment();
         screen.add_L3_comment("error in closing the ticket");
         Print("error in closing the ticket");
         return 0;
      }
   }
   screen.clear_L3_comment();
   screen.add_L3_comment("error in selecting the ticket");
   Print("error in selecting the ticket");
   return 0;

}
int handle()
{  //returns 1 if closes the trade to return to base state
   //0 if the position remains still
   int return_closed=0;

   double rsi1 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,1); 
   double rsi2 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,2); 
   double rsi3 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,3); 
//   double new_open_rsi = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_OPEN ,0,0); 

   if(OrderSelect(open_ticket,SELECT_BY_TICKET)) 
   {
      switch(OrderType())
      {
         case OP_BUY:
            if(rsi1<=rsi2 && rsi2<=rsi3)
               return_closed = close_order(open_ticket);
            break;
         case OP_SELL:
            if(rsi1>=rsi2 && rsi2>=rsi3)
               return_closed = close_order(open_ticket);
            break;
         default:    //unexpected order type
         screen.clear_L3_comment();
         screen.add_L3_comment("unexpected order type");
         Print("unexpected order type");
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
