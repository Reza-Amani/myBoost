//+------------------------------------------------------------------+
//|                                                 EA7_patterns.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      ""
#property version   "1.00"
#property strict

#include <MyHeaders\Tools\MyMath.mqh>
#include <MyHeaders\Tools\Screen.mqh>
#include <MyHeaders\Tools\Tools.mqh>
#include <MyHeaders\Operations\MoneyManagement.mqh>
#include <MyHeaders\Operations\StopLoss.mqh>
#include <MyHeaders\Operations\TradeControl.mqh>
#include <MyHeaders\Operations\PeakEater.mqh>
#include <MyHeaders\Crits\CritPeakDigester.mqh>
#include <MyHeaders\Crits\CritParabolicLover.mqh>
#include <MyHeaders\Crits\CritPeakOrderer.mqh>
#include <MyHeaders\Crits\CritRelativeVolatility.mqh>
#include <MyHeaders\Crits\CritPeakQuality.mqh>
#include <MyHeaders\Crits\CritPeakSimple.mqh>

enum OpenAlgo
{
   OPEN_EARLY,
//   OPEN_ONLY_CONFIRM,
};
enum CloseAlgo
{
   CLOSE_EARLY
};
///////////////////////////////inputs
input int      RSI_len=28;
input int      filter_len=50;
input CloseAlgo   close_algo=CLOSE_EARLY; 
input OpenAlgo    open_algo=OPEN_EARLY;
input bool use_parabolic_lover=false;
input bool use_digester=false;
input bool use_orderer=false;
input bool use_volatility=false;
input bool use_peak_q=false;
input bool use_simpler=true;
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
PeakDigester digester(1);
ParabolicLover parabol(1,sl_SAR_step,0.2);
PeakOrderer orderer(1);
RelativeVolatility volatility(1,100);
PeakQuality peak_quality(1);
PeakSimple simpler(1);
//int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
//int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open(PeakEaterResult _peaks_return, double _rsi1, double _new_peak)
{
   double order_q,digest_q,SAR_q,volatility_q,peak_q,simpler_q,total_q;
   switch(open_algo)
   {
      case OPEN_EARLY:
         switch(_peaks_return)
         {
            case RESULT_CONFIRM_A:
               order_q = (use_orderer)? orderer.get_advice(false) : 1;
               digest_q = (use_digester)? digester.get_advice(false) : 1;
               SAR_q = (use_parabolic_lover)? parabol.get_advice(false,0) : 1;
               volatility_q = (use_volatility)? volatility.get_advice(false) : 1;
               peak_q = (use_peak_q)? peak_quality.get_advice(false) : 1;
               simpler_q = (use_simpler)? simpler.get_advice(false) : 1;
               total_q = simpler_q*order_q*digest_q*SAR_q*peak_q*volatility_q;
               if(total_q>0)
               {
                  double sl = stop_loss.get_sl(false,Bid);
                  double equity=AccountEquity();
                  double lots = total_q;//money.get_lots(lots_base*total_q,Ask,sl,equity);
                  if(sl>0)
                     trade.sell(lots,sl,0);
               }
               break;
            case RESULT_CONFIRM_V:
               order_q = (use_orderer)? orderer.get_advice(true) : 1;
               digest_q = (use_digester)? digester.get_advice(true) : 1;
               SAR_q = (use_parabolic_lover)?parabol.get_advice(true,0) : 1;
               volatility_q = (use_volatility)? volatility.get_advice(true) : 1;
               peak_q = (use_peak_q)? peak_quality.get_advice(true) : 1;
               simpler_q = (use_simpler)? simpler.get_advice(true) : 1;
               total_q = simpler_q*order_q*digest_q*SAR_q*peak_q*volatility_q;
               if(total_q>0)
               {
                  double sl = stop_loss.get_sl(true,Ask);
                  double  equity=AccountEquity();
                  double lots = total_q;//money.get_lots(lots_base*total_q,Ask,sl,equity);
                  if(sl>0)
                     trade.buy(lots,sl,0);
               }
               break;
         }
         break;
   }
   
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void trailing_sl(bool _for_buy)
{
   double new_sl=stop_loss.get_sl(_for_buy,Close[0]);
   if(new_sl>0)
      trade.edit_sl(new_sl);
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
      case CLOSE_EARLY:
         if(buy_trade)
            if(rsi1<rsi2)
               trade.close();
         if(!buy_trade)
            if(rsi1>rsi2)
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
      
      //-----------------------------------------------------------------------------------------------------------------charging Crits
      digester.take_input(peaks_return,new_peak,rsi1);
      parabol.take_input(0);
      orderer.take_input(new_peak ,peaks.V0,peaks.V1,peaks.V2,peaks.A0,peaks.A1,peaks.A2);
      volatility.take_input();
      peak_quality.take_input(new_peak ,peaks.V0,peaks.V1,peaks.V2,peaks.A0,peaks.A1,peaks.A2);
      simpler.take_input(new_peak ,peaks.V0,peaks.V1,peaks.V2,peaks.A0,peaks.A1,peaks.A2);
      
      screen.clear_L5_comment();
      screen.add_L5_comment(peaks.get_report());
      
      if(trade.have_open_trade())
      {
         trailing_sl(trade.is_buy_trade());  
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
