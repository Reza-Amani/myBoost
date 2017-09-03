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
#include <MyHeaders\PeakDigester.mqh>

enum OpenAlgo
{
   OPEN_ONLY_CONFIRM,
   OPEN_ADAPTIVE,
   OPEN_EARLY
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
input CloseAlgo   close_algo=CLOSE_FLOW_EARLY; 
input OpenAlgo    open_algo=OPEN_EARLY;
input bool use_digester=true;
input bool use_order_quality=true;
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
PeakDigester digester();
//int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
//int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open(int _peaks_return, double _rsi1, double _new_peak)
{
   int order_q,digest_q,total_q;
   switch(open_algo)
   {
      case OPEN_ONLY_CONFIRM:
         break;
      case OPEN_ADAPTIVE:
         break;
      case OPEN_EARLY:
         switch(_peaks_return)
         {
            case RESULT_CANDIDATE_A:
               order_q = (use_order_quality)? peaks.get_buy_peak_order_quality() : 1;
               digest_q = (use_digester)? digester.get_buy_dish() : 1;
               total_q = order_q*digest_q;
               if(order_q>0 && digest_q>0)
               {
                  double sl = stop_loss.get_sl();
                  if(sl>=Ask)
                     sl=0;
                  double  equity=AccountEquity();
                  double lots = total_q;//money.get_lots(lots_base*total_q,Ask,sl,equity);
                  trade.buy(lots,sl,0);
               }
               break;
            case RESULT_CANDIDATE_V:
               order_q = (use_order_quality)? peaks.get_sell_peak_order_quality() : 1;
               digest_q = (use_digester)? digester.get_sell_dish() : 1;
               total_q = order_q*digest_q;
               if(order_q>0 && digest_q>0)
               {
                  double sl = stop_loss.get_sl();
                  if(sl<=Ask)
                     sl=0;
                  double  equity=AccountEquity();
                  double lots = total_q;//money.get_lots(lots_base*total_q,Ask,sl,equity);
                  trade.sell(lots,sl,0);
               }
               break;
         }
         break;
   }
//   double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,1); 
//   double rsi2 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,2); 
//   double rsi3 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,3); 
//   double rsi4 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,4); 
//   double buy_quality = iCustom(Symbol(), Period(),"myIndicators/swing_quality", RSI_len, 0,1); //TODO: consider it. >18 and >35
//   double sell_quality = iCustom(Symbol(), Period(),"myIndicators/swing_quality", RSI_len, 1,1); 
//   double slow_total_quality = iCustom(Symbol(), Period(),"myIndicators/swing_quality", RSI_len, 3,1); 

//   double peak_flow = iCustom(Symbol(), Period(),"myIndicators/RSIpeaksAve", RSI_len, filter_len, 3,1); //TODO: consider it. peak_flow>70, rsi cross above valey_flow
//   double valey_flow = iCustom(Symbol(), Period(),"myIndicators/RSIpeaksAve", RSI_len, filter_len, 4,1); 
   
   
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
//         double sl = stop_loss.get_sl();
//         double  equity=AccountEquity();
//         double lots = money.get_lots(lots_base*(desire_level-1),Ask,sl,equity);
//         trade.buy(lots,sl,0);
   
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

      double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,1); 
      PeakEaterResult peaks_return;
      double new_peak;
      peaks_return = peaks.take_sample(rsi1,new_peak);
      digester.take_event(peaks_return,new_peak);
      screen.clear_L5_comment();
      screen.add_L5_comment(peaks.get_report());
      
      if(trade.have_open_trade())
      {
         trailing_sl();  
         check_for_close();
      }
      if(!trade.have_open_trade())
         if(peaks_return!=RESULT_CONTINUE)
            check_for_open(peaks_return,rsi1,new_peak);
            
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
