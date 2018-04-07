//+------------------------------------------------------------------+
//|                                                 EA7_patterns.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      ""
#property version   "1.00"
#property strict

//#include <MyHeaders\Tools\MyMath.mqh>
#include <MyHeaders\Tools\Screen.mqh>
//#include <MyHeaders\Tools\Tools.mqh>
//#include <MyHeaders\Operations\MoneyManagement.mqh>
//#include <MyHeaders\Operations\StopLoss.mqh>
//#include <MyHeaders\Operations\TakeProfit.mqh>
#include <MyHeaders\Operations\TradeControl.mqh>
#include <MyHeaders\BarProfiler.mqh>

///////////////////////////////inputs
input double   lots_base = 1;
input bool ECN = false;

double lots =  lots_base;
//////////////////////////////parameters
//////////////////////////////objects
BarProfiler bar(Open[0]);
Screen screen;
TradeControl trade(ECN);
/*MyMath math;
MoneyManagement money(lots_base);
StopLoss stop_loss(sl_SAR_step, 0.2);
TakeProfit take_profit(tp_factor_sl);
*/
//int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
//int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open()
{
   if(bar.GetPred(Pred_OnlyDir)==1)
      trade.buy(lots,0,0);
   if(bar.GetPred(Pred_OnlyDir)==-1)
      trade.sell(lots,0,0);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void  check_for_close()
{  //returns 1 if closes the trade to return to base state
   //0 if the position remains still
   bool buy_trade=trade.is_buy_trade();
               trade.close();
   
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

      bar.UpdateResult((Close[1]>Open[1])?1:-1);   //update the results for the last bar; don't renew bar data before this
      
      bar.UpdateData(Open[1], Close[1], High[1], Low[1]);
      bar.UpdatePrevData( (Close[2]>Open[2])?1:-1, (Close[3]>Open[3])?1:-1 );
   
//      screen.clear_L5_comment();
//      screen.add_L5_comment("macd "+DoubleToString(macd_macd)+"sig "+DoubleToString(macd_sig_ma)+"force "+DoubleToString(macd_force)+"dforce "+DoubleToString(macd_dforce));
      
//      screen.clear_L1_comment();
//      screen.add_L1_comment("bars:"+IntegerToString(bars));
            
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
