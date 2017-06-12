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
input int      correlation_thresh=90;
input int      thresh_hC=30;  
                  //30 means: 2*0.65-1
input int      thresh_aC=40;
                  //40 means: 0.4
input int      min_hit=25;
input int      max_hit=100;
input ConcludeCriterion criterion=USE_aveC1;
input int      lookback_len=6000;
input double   i_Lots=1;
//////////////////////////////parameters
int processed_bars=0;
int trade_id=0;
int state=0;
int trade_counter=0;
//////////////////////////////objects
Screen screen;
int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
int search()
{  //returns 1 if opens a trade to proceed to next state
   //0 if unsuccessful search
   processed_bars++;
   screen.add_L2_comment(" bars:"+IntegerToString(processed_bars));

   Pattern* p_pattern;
   ExamineBar* p_bar;
   Pattern moving_pattern;

   int _ref=0;//only to keep compatibility with the script
   p_pattern=new Pattern(Close,_ref,pattern_len,0);
      //TODO: replace with Open,0 
   p_bar=new ExamineBar(_ref,p_pattern);
   
   for(int j=10+_ref;j<_ref+lookback_len-pattern_len;j++)
   {
      moving_pattern.set_data(Close,j,pattern_len,Close[j-1]);
      if(p_bar.check_another_bar(moving_pattern,correlation_thresh,max_hit))
         break;
   }
   if(p_bar.conclude(criterion,min_hit,thresh_hC,thresh_aC))
   {  //a famous and good bar!
      p_bar.log_to_file_tester(outfilehandle);
      p_bar.log_to_file_common(outfilehandle);
      trade_counter++;
      if(p_bar.direction==1)
         OrderSend(Symbol(),OP_BUY, i_Lots, Ask, 0, Ask/2,Ask*2,NULL,++trade_id,0,clrAliceBlue);
      else if(p_bar.direction==-1)
         OrderSend(Symbol(),OP_SELL, i_Lots, Bid, 0, Bid*2,Bid/2,NULL,++trade_id,0,clrAliceBlue);
      delete p_bar;
      delete p_pattern;
      screen.clear_L2_comment();
      screen.add_L2_comment("tradecnt:"+IntegerToString(trade_counter));
      screen.clear_L3_comment();
      screen.add_L3_comment("trade placed");
      return 1;
   }
   delete p_bar;
   delete p_pattern;
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
   if(file<0 || outfilehandle<0)
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
   FileWrite(file,"processed bars:", processed_bars," trade cnt", trade_counter);
}
void OnTick()
{
   if(IsTradeAllowed()==false)
      return;
   //just wait for new bar
   static datetime Time0=0;
   if (Time0 == Time[0])
      return;
   int history_bars=Bars-10-pattern_len;
   if(history_bars<=lookback_len)
      return;   //not enough history

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
//+------------------------------------------------------------------+
