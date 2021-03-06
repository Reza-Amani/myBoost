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
//#include <MyHeaders\Tools\Tools.mqh>
//#include <MyHeaders\Operations\MoneyManagement.mqh>
#include <MyHeaders\Operations\StopLoss.mqh>
//#include <MyHeaders\Operations\TakeProfit.mqh>
#include <MyHeaders\Operations\TradeControl.mqh>
#include <MyHeaders\BarProfiler.mqh>

enum RuleSelector
{
   RuleSelectorSingle,
   RuleSelectorMaxer,
   RuleSelectorFirstGood,
   RuleSelectorDemocracy
};
///////////////////////////////inputs
input BarPredRule rule;
input int filter=100;
input bool use_quality=false;
input bool keep_losing_position=false;
input RuleSelector rule_selector=RuleSelectorFirstGood;
input bool use_history=true;
input bool use_sl_tp=true;
input double sl_factor=2;
input double tp_factor=2;
input double   lots_base = 1;
input bool ECN = false;

double lots =  lots_base;
//////////////////////////////parameters
//////////////////////////////objects
BarProfiler bar(High[1],Low[1],filter);
Screen screen;
TradeControl trade(ECN);
MyMath math;
StopLoss sl((use_sl_tp)?SL_BARSIZE:SL_NONE, sl_factor, 0);
/*
MoneyManagement money(lots_base);
TakeProfit take_profit(tp_factor_sl);
*/
int file_handle=FileOpen("./tradefiles/F"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_rule"+EnumToString(rule)+".csv",FILE_WRITE|FILE_CSV,',');
#define cont    FileSeek(file_handle,-2,SEEK_CUR)

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open()
{
   double vote;
   BarPredRule active_rule=0;
   double sl_buy=sl.get_sl(true, Open[0], bar.ave_barsize, 0);
   double sl_sell=sl.get_sl(false, Open[0], bar.ave_barsize, 0);
   switch(rule_selector)
   {
      case RuleSelectorSingle:
         active_rule=rule;
         lots = lot_manager(lots_base, use_quality, (bar.quality[(int)active_rule]>0)?1:0.1, (double)active_rule);
         if(bar.GetPred(active_rule)>0)
            trade.buy_if_no_trade(lots,sl_buy,0,keep_losing_position);
         if(bar.GetPred(active_rule)<0)
            trade.sell_if_no_trade(lots,sl_sell,0,keep_losing_position);
         break;
      case RuleSelectorMaxer:
         active_rule=bar.GetBestRule();
         lots = lot_manager(lots_base, use_quality, (bar.quality[(int)active_rule]>0)?1:0.1, (double)active_rule);
         if(bar.GetPred(active_rule)>0)
            trade.buy_if_no_trade(lots,sl_buy,0,keep_losing_position);
         if(bar.GetPred(active_rule)<0)
            trade.sell_if_no_trade(lots,sl_sell,0,keep_losing_position);
         break;
      case RuleSelectorFirstGood:
         active_rule= bar.GetFirstGood();
         if(active_rule!=Pred_size)
         {
            lots = lot_manager(lots_base, use_quality, (bar.quality[(int)active_rule]>0)?1:0.5, (double)active_rule);
            if(bar.GetPred(active_rule)>0)
               trade.buy_if_no_trade(lots,sl_buy,0,keep_losing_position);
            if(bar.GetPred(active_rule)<0)
               trade.sell_if_no_trade(lots,sl_sell,0,keep_losing_position);
         }
         break;      
      case RuleSelectorDemocracy:
         vote = bar.GetPredWaightedDemocracy();
         lots = lot_manager(lots_base, use_quality, vote, 1);
         if(vote>0)
            trade.buy_if_no_trade(lots,sl_buy,0,keep_losing_position);
         if(vote<0)
            trade.sell_if_no_trade(lots,sl_sell,0,keep_losing_position);
         break;
   }
}

double lot_manager(double _lot_base, bool _use_quality, double _hope, double _magic_no)
{
   double lot_result=0;
   lot_result = _lot_base*(1+_magic_no*0.1);
   if(_use_quality)
      lot_result *= math.abs(_hope);
   return lot_result;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
void  check_for_close()
{  //returns 1 if closes the trade to return to base state
   //0 if the position remains still
   bool buy_trade=trade.is_buy_trade();
               trade.close();
   
}
*/
//+------------------------------------------------------------------+
//| standard function                                                |
//+------------------------------------------------------------------+
int OnInit()
{
   screen.clear_L1_comment();
   screen.add_L1_comment("EA started-");
   if(file_handle<0)
   {
      screen.add_L1_comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return(INIT_FAILED);
   }
   else
      screen.add_L1_comment("file ok-");
   
   FileWrite(file_handle,"Bar","cprice","dir",                 "history",       "Nchange"," quality");

   int history_bars = math.min(Bars, 1000) - 3 -10; //-10 is just in case, as a marging for future development
   if(use_history && history_bars>10)
   {
      for(int i=history_bars; i>0; i--)
      {
         bar.UpdateResult((Close[i]>Open[i])?1: ((Close[i]<Open[i])?-1:0) );
            
         bar.UpdateData(Open[i], Close[i], High[i], Low[i]);
         bar.UpdatePrevData( (Close[i+1]>Open[i+1])?1:-1, (Close[i+2]>Open[i+2])?1:-1 );
      }
      screen.add_L1_comment("history("+IntegerToString(history_bars)+")processed-");
   }
   else
      screen.add_L1_comment("no history processed-");
   return(INIT_SUCCEEDED);
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

      bar.UpdateResult((Close[1]>Open[1])?1: ((Close[1]<Open[1])?-1:0) );   //update the results for the last bar; don't renew bar data before this
      cont;      
      FileWrite(file_handle,"", Close[1]-Open[1], bar.quality[rule]);

      bar.UpdateData(Open[1], Close[1], High[1], Low[1]);
      bar.UpdatePrevData( (Close[2]>Open[2])?1:-1, (Close[3]>Open[3])?1:-1 );
   
      FileWrite(file_handle,bars,Close[1],bar.GetDirection(), bar.GetHistory());

//      screen.clear_L5_comment();
//      screen.add_L5_comment("macd "+DoubleToString(macd_macd)+"sig "+DoubleToString(macd_sig_ma)+"force "+DoubleToString(macd_force)+"dforce "+DoubleToString(macd_dforce));
      
//      screen.clear_L1_comment();
//      screen.add_L1_comment("bars:"+IntegerToString(bars));
            
//      if(trade.have_open_trade())
//      {
/*         double new_sl=stop_loss.get_sl(trade.is_buy_trade(),Close[0], trade.is_buy_trade()?Low[1]:High[1]);
         double new_tp=take_profit.get_tp(trade.is_buy_trade(),new_sl,Close[0]);
         if(new_sl>0)
            trade.edit_sl(new_sl);
         if(new_tp>0)
            trade.edit_tp(new_tp);
*/
//         check_for_close();
//      }
//      if(!trade.have_open_trade())
//         check_for_open();
      check_for_open();            
      string trade_report=trade.get_report();
      if(trade_report!="")
      {
         trade.clear_report();
         screen.clear_L2_comment();
         screen.add_L2_comment(trade_report);
         Print(trade_report);
      }
      screen.clear_L3_comment();
      screen.add_L3_comment("spread(5-digit,MT4)= "+IntegerToString((Ask-Bid)*100000));
      screen.add_L3_comment(" filters: ");
      for(int i=0; i<Pred_size; i++)
         screen.add_L3_comment(" "+IntegerToString(i)+"="+DoubleToString(bar.quality[i],2));
        

   }
}
//+------------------------------------------------------------------+
