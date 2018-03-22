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
#include <MyHeaders\Operations\TakeProfit.mqh>
#include <MyHeaders\Operations\TradeControl.mqh>
#include <MyHeaders\Operations\PeakEater.mqh>
#include <MyHeaders\Crits\CritParabolicLover.mqh>
#include <MyHeaders\Crits\CritRelativeVolatility.mqh>
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
input double   lots_base = 1;
input int MACD_len=13;
input int MACD_ma=9;
input bool ECN = false;

      double macd_macd=0; 
      double macd_sig_ma=0; 
      double macd_force=0; 
      double macd_dforce=0; 
double lots =  lots_base;
/*input int      RSI_len=30;
input int      schmitt_threshold=4;
input int  simpler_thresh=30;
input bool set_sl=true;
input double tp_factor_sl=2;
input double   sl_SAR_step=0.01; 
input bool twin_peaks=true;
input CloseAlgo   close_algo=CLOSE_EARLY; 
input OpenAlgo    open_algo=OPEN_EARLY;
input bool use_parabolic_lover=false;
input bool use_volatility=false;
input bool use_simpler=true;
*/
//////////////////////////////parameters
//////////////////////////////objects
Screen screen;
TradeControl trade(ECN);
/*MyMath math;
MoneyManagement money(lots_base);
StopLoss stop_loss(sl_SAR_step, 0.2);
TakeProfit take_profit(tp_factor_sl);
PeakEater peaks();
ParabolicLover parabol(1,sl_SAR_step,0.2);
RelativeVolatility volatility(1,100);
PeakSimple simpler(simpler_thresh,1,twin_peaks,3);
*/
//int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
//int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open()
{
   if(/*macd_macd>0 &&*/ macd_force>0 && macd_dforce>0)
      trade.buy(lots,0,0);
   if(/*macd_macd<0 &&*/ macd_force<0 && macd_dforce<0)
      trade.sell(lots,0,0);

/*   switch(open_algo)
   {
      case OPEN_EARLY:
         switch(_peaks_return)
         {
            case RESULT_CONFIRM_A:
               SAR_q = (use_parabolic_lover)? parabol.get_advice(false,0) : 1;
               volatility_q = (use_volatility)? volatility.get_advice(false) : 1;
               simpler_q = (use_simpler)? simpler.get_advice(false,_rsi1) : 1;
               total_q = simpler_q*SAR_q*volatility_q;
               if(total_q>0)
               {
                  double sl = stop_loss.get_sl(false,Bid, High[1]);
                  double tp = take_profit.get_tp(false,sl,Bid);
                  double equity=AccountEquity();
                  double lots = money.get_lots(lots_base*total_q,Bid,sl,equity);
                  screen.clear_L3_comment();
                  screen.add_L3_comment("sell? ");
                  if(set_sl)
                  {
                     screen.add_L3_comment("sl:"+DoubleToString(sl));
                     if(sl>0)
                        trade.sell(lots,sl,tp);
                  }
                  else
                     trade.sell(lots,0,0);
               }
               screen.add_L3_comment("-");
               break;
            case RESULT_CONFIRM_V:
               SAR_q = (use_parabolic_lover)?parabol.get_advice(true,0) : 1;
               volatility_q = (use_volatility)? volatility.get_advice(true) : 1;
               simpler_q = (use_simpler)? simpler.get_advice(true,_rsi1) : 1;
               total_q = simpler_q*SAR_q*volatility_q;
               if(total_q>0)
               {
                  double sl = stop_loss.get_sl(true,Ask, Low[1]);
                  double tp = take_profit.get_tp(true,sl,Ask);
                  double  equity=AccountEquity();
                  double lots = money.get_lots(lots_base*total_q,Ask,sl,equity);
                  screen.clear_L3_comment();
                  screen.add_L3_comment("buy? ");
                  if(set_sl)
                  {
                     screen.add_L3_comment("sl:"+DoubleToString(sl));
                     if(sl>0)
                        trade.buy(lots,sl,tp);
                  }
                  else
                     trade.buy(lots,0,0);
               }
               screen.add_L3_comment("-");
               break;
            default:
               screen.add_L3_comment(".");
               break;
         }
         break;
   }
*/   
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void  check_for_close()
{  //returns 1 if closes the trade to return to base state
   //0 if the position remains still
   bool buy_trade=trade.is_buy_trade();
//   switch(close_algo)
   {
//      case CLOSE_EARLY:
         if(buy_trade)
            if(macd_dforce<0 )
               trade.close();
         if(!buy_trade)
            if(macd_dforce>0)
               trade.close();
//         break;
   }
}
//+------------------------------------------------------------------+
//| standard function                                                |
//+------------------------------------------------------------------+
int OnInit()
{
   screen.add_L1_comment("EA started-");
//      process_past_peaks();
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
   static int bars=0;
   //just wait for new bar
   static datetime Time0=0;
   if (Time0 == Time[0])
   {  //check for RSI-based sl/tp during the bar here
      return;
   }
   else
   {  //new bar; main process
      Time0 = Time[0];
      bars++;
      
      macd_macd = iCustom(Symbol(), Period(),"myIndicators/myMACD", MACD_len, MACD_ma, 0,1); 
      macd_sig_ma = iCustom(Symbol(), Period(),"myIndicators/myMACD", MACD_len, MACD_ma, 1,1); 
      macd_force = iCustom(Symbol(), Period(),"myIndicators/myMACD", MACD_len, MACD_ma, 2,1); 
      macd_dforce = iCustom(Symbol(), Period(),"myIndicators/myMACD", MACD_len, MACD_ma, 3,1); 
/*      PeakEaterResult peaks_return;
      peaks_return = peaks.take_sample(rsi1);
      
      //-----------------------------------------------------------------------------------------------------------------charging Crits
      parabol.take_input(0);
      volatility.take_input();
      simpler.take_input(peaks.V0,peaks.V1,peaks.V2,peaks.A0,peaks.A1,peaks.A2);
*/      
      screen.clear_L5_comment();
      screen.add_L5_comment("macd "+DoubleToString(macd_macd)+"sig "+DoubleToString(macd_sig_ma)+"force "+DoubleToString(macd_force)+"dforce "+DoubleToString(macd_dforce));
      
      screen.clear_L1_comment();
      screen.add_L1_comment("bars:"+IntegerToString(bars));
      
      if(trade.have_open_trade())
      {
/*         double new_sl=stop_loss.get_sl(trade.is_buy_trade(),Close[0], trade.is_buy_trade()?Low[1]:High[1]);
         double new_tp=take_profit.get_tp(trade.is_buy_trade(),new_sl,Close[0]);
         if(new_sl>0)
            trade.edit_sl(new_sl);
         if(new_tp>0)
            trade.edit_tp(new_tp);
*/         check_for_close();
      }
      if(!trade.have_open_trade())
         check_for_open();
            
      string trade_report=trade.get_report();
      if(trade_report!="")
      {
         trade.clear_report();
         screen.clear_L2_comment();
         screen.add_L2_comment(trade_report);
         Print(trade_report);
      }
   }
}
//+------------------------------------------------------------------+
