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
#include <MyHeaders\PeakEater.mqh>

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
input CloseAlgo     close_algo=CLOSE_FLOW_EARLY; 
input double   sl_SAR_step=0.01; 
input double   lots_base = 1;
//////////////////////////////parameters
//////////////////////////////objects
Screen screen;
MyMath math;
MoneyManagement money(lots_base);
StopLoss stop_loss(sl_SAR_step, 0.2);
TradeControl trade();
PeakEater peaks();
//int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
//int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open()
{
   double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,1); 
   double rsi2 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,2); 
   double rsi3 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,3); 
   double rsi4 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,4); 
   double buy_quality = iCustom(Symbol(), Period(),"myIndicators/swing_quality", RSI_len, 0,1); //TODO: consider it. >18 and >35
   double sell_quality = iCustom(Symbol(), Period(),"myIndicators/swing_quality", RSI_len, 1,1); 
   double slow_total_quality = iCustom(Symbol(), Period(),"myIndicators/swing_quality", RSI_len, 3,1); 

   double peak_flow = iCustom(Symbol(), Period(),"myIndicators/RSIpeaksAve", RSI_len, filter_len, 3,1); //TODO: consider it. peak_flow>70, rsi cross above valey_flow
   double valey_flow = iCustom(Symbol(), Period(),"myIndicators/RSIpeaksAve", RSI_len, filter_len, 4,1); 
   
   double sl=stop_loss.get_sl();
   
/*      case SEARCH_PEAK_AGGRESSIVE:
         thresh_buy=(int)valey_flow;
         thresh_sell=(int)peak_flow;
         if( (peak_flow>=70 && rsi2<=thresh_buy && rsi1>=thresh_buy)
            ||(peak_flow>=70 && rsi2<=thresh_buy && rsi1>=10+math.min(rsi2,rsi3,rsi4)))
         {
            double tp=0;
            tp=100+buy_quality;
            double  equity=AccountEquity();
            double lots = money.get_lots(1,Ask,sl,equity);
            screen.clear_L3_comment();
            screen.add_L3_comment("lots="+DoubleToString(lots));
            if(lots<0.01)
               screen.add_L3_comment("-----insufficient lots");
            else
               if(Open[0]>sl)
                  trade.buy(lots,sl,tp);
*/
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void trailing_sl()
{
   trade.edit_sl(stop_loss.get_sl());
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void  check_for_close()
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

   bool buy_trade=trade.is_buy_trade();
   double max=math.max(rsi2,rsi3,rsi4);
   switch(close_algo)
   {
      case CLOSE_AGGRESSIVE:
         if(rsi3>70 && rsi1<rsi2 && rsi1<rsi3)
            trade.close();
         else if(rsi2>80 && rsi1<rsi2)
            trade.close();
         else if(rsi3<=70 && rsi1<rsi2 && rsi1<rsi3-15)
            trade.close();
         else if(rsi4<=70 && rsi1<=rsi2 && rsi2<=rsi3 && rsi3<=rsi4)
            trade.close();
         else if(rsi1<30 && rsi2>=30)
            trade.close();
         break;
      case CLOSE_CONSERVATIVE:
         if(rsi1<=rsi2 && rsi2<=rsi3)
            trade.close();
         break;
      case CLOSE_FLOW_CONSERVATIVE:
         if(rsi1<=rsi2 && rsi1<=rsi3-15)
            trade.close();
         else if(rsi1<=peak_flow && rsi2>=peak_flow)
            trade.close();
         break;
      case CLOSE_FLOW_EARLY:
         if(rsi1<=peak_flow && rsi2>=peak_flow)
            trade.close();
         else if(max>peak_flow && rsi1<=max-5)
            trade.close();
         else if(rsi1<=max-10)
            trade.close();
         else if(max==99 && rsi1<99)
            trade.close();
         break;
   }
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
   return 0;
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

      if(trade.have_open_trade())
      {
         trailing_sl();  
         check_for_close();
      }
      else
         check_for_open();
      string report=trade.get_report();
      if(report!="")
      {
         trade.clear_report();
         screen.clear_L2_comment();
         screen.add_L2_comment(report);
         Print(report);
      }
   }
}
//+------------------------------------------------------------------+