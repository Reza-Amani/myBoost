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
#include <MyHeaders\Pattern.mqh>
#include <MyHeaders\ExamineBar.mqh>
#include <MyHeaders\Screen.mqh>
#include <MyHeaders\Tools.mqh>

///////////////////////////////inputs
input int      pattern_len=12;
input int      correlation_thresh=94;
input int      hit_threshold=70;
input int      min_hit=40;
input int      max_hit=100;
input int      history=20000;
input double   i_Lots=1;
//////////////////////////////parameters
int history_size;
int processed_bars=0;
int trade_id=0;
int state=0;
//////////////////////////////objects
Screen screen;
int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
int search()
{  //returns 1 if opens a trade to proceed to next state
   //0 if unsuccessful search
   history_size=(int)MyMath::min(Bars-100,history);
   processed_bars++;
   screen.add_L2_comment("History:"+IntegerToString(history_size));
   screen.add_L2_comment(" bars:"+IntegerToString(processed_bars));
   
   Pattern now_pattern(Close,1,pattern_len,0);
   ExamineBar examine(0,&now_pattern);
   Pattern moving_pattern;
   for(int i=10;i<history_size;i++)
   {
      moving_pattern.set_data(Close,i,pattern_len,Close[i-1]);
      if(examine.check_another_bar(moving_pattern,correlation_thresh,max_hit))
         break;
   }
   if(examine.number_of_hits>min_hit)
   {  //a famous bar!
      if(100*examine.higher_c1/examine.number_of_hits >= hit_threshold)
      {  
         examine.log_to_file(file);
         OrderSend(Symbol(),OP_BUY, i_Lots, Ask, 0, Ask/2,Ask*2,NULL,++trade_id,0,clrAliceBlue);
         return 1;
      }
   }
   return 0;
}
int handle()
{  //returns 1 if closes the trade to return to base state
   //0 if remains here
   close_positions();
   return 1;
}
void    close_positions()
{
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==false) continue; 
      if(OrderType()==OP_BUY) 
         OrderClose(OrderTicket(),OrderLots(),Bid,3);
      else if(OrderType()==OP_SELL)
         OrderClose(OrderTicket(),OrderLots(),Ask,3);
      else
         OrderDelete(OrderTicket(),clrGray);
   }
}
//+------------------------------------------------------------------+
//| standard function                                                |
//+------------------------------------------------------------------+
int OnInit()
{
   screen.add_L1_comment("EA started-");
   if(file<0)
   {
      screen.add_L1_comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return(INIT_FAILED);
   }
   screen.add_L1_comment("file ok-");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}
void OnTick()
{
   if(IsTradeAllowed()==false)
      return;
   //just wait for new bar
   static datetime Time0=0;
   if (Time0 == Time[0])
      return;
   Time0 = Time[0];
   screen.clear_L2_comment();
   
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
//+------------------------------------------------------------------+
