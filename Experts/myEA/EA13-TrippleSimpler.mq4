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
#include <MyHeaders\Crits\CritPeakSimple.mqh>

///////////////////////////////inputs
input double   lots_base = 0.1;
input bool ECN = false;
input int      schmitt_threshold=4;
input int  simpler_thresh=30;
input int ave_len=3;
input bool set_sl=true;
input double tp_factor_sl=2;
input double   sl_SAR_step=0.01; 
//////////////////////////////parameters
#define SARS   3
int RSI_len[6]={20,28,40,56,80,112};
//int RSI_len[6]={20,28,40,56,80,112};
//////////////////////////////objects
Screen screen;
MyMath math;
MoneyManagement money(lots_base);
StopLoss stop_loss(sl_SAR_step, 0.2);
TakeProfit take_profit(tp_factor_sl);
TradeControl trade(ECN);
PeakEater * peaks[SARS];
PeakSimple * simple_crit[SARS];
//int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
//int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open(int _best_index, double _rsi1, double _rsi2, double _rsi3)
{
   double advice = simple_crit[_best_index].get_advice(_rsi1, _rsi2, _rsi3);
   if(advice==-1)
   {
      double sl = stop_loss.get_sl(false,Bid, High[1]);
      double tp = take_profit.get_tp(false,sl,Bid);
      double equity=AccountEquity();
      double lots = money.get_lots(lots_base,Bid,sl,equity);
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
   else if(advice==1)
   {
      double sl = stop_loss.get_sl(true,Ask, Low[1]);
      double tp = take_profit.get_tp(true,sl,Ask);
      double  equity=AccountEquity();
      double lots = money.get_lots(lots_base,Ask,sl,equity);
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
   else if(advice==0.1)
      screen.add_L3_comment(",");
   else if(advice==-0.1)
      screen.add_L3_comment("'");
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void  check_for_close(double rsi1, double rsi2)
{
   bool buy_trade=trade.is_buy_trade();
   if(buy_trade)
      if(rsi1<rsi2)
         trade.close();
   if(!buy_trade)
      if(rsi1>rsi2)
         trade.close();
}
//--------------------------------------------------------------------
void process_past_peaks()
{
   int past_bars = (int)math.min(Bars,70);
   for(int i=past_bars; i>0; i--)
      for( int j=0; j<SARS;j++)
      {
         double rsi1 = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", RSI_len[j], schmitt_threshold, 0,i); 
         peaks[j].take_sample(rsi1);
      }
   screen.add_L1_comment("past_bars="+IntegerToString(past_bars));
   screen.clear_L5_comment();
   screen.add_L5_comment("past:"+peaks[0].get_report());
}
//+------------------------------------------------------------------+
//| standard function                                                |
//+------------------------------------------------------------------+
int OnInit()
{
   int i;
   for( i=0; i<SARS;i++)
      simple_crit[i] = new PeakSimple(simpler_thresh,1,true,ave_len);
   for( i=0; i<SARS;i++)
      peaks[i] = new PeakEater();
      
   screen.add_L1_comment("EA started-");
   process_past_peaks();
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
   int i;
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
      
      double rsi1[SARS];
      for( i=0; i<SARS;i++)
         rsi1[i] = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", RSI_len[i], schmitt_threshold, 0,1); 
      
      for( i=0; i<SARS;i++)
         peaks[i].take_sample(rsi1[i]);
      
      for( i=0; i<SARS;i++)
         simple_crit[i].take_input(peaks[i].V0,peaks[i].V1,peaks[i].V2,peaks[i].A0,peaks[i].A1,peaks[i].A2);
      
      screen.clear_L5_comment();
      screen.add_L5_comment(peaks[0].get_report());
      
      screen.clear_L1_comment();
      screen.add_L1_comment("bars:"+IntegerToString(bars));
      
      //determining the best SAR len
      int best_index=0;
      double best_mood=0;
      for( i=0; i<SARS;i++)
      {
         double moodi = simple_crit[i].get_mood(rsi1[i],peaks[i].is_rising());
         if(moodi > best_mood)
         {
            best_mood = moodi;
            best_index = i;
         }
      }
      
      if(trade.have_open_trade())
      {
         if(set_sl)
         {
            double new_sl=stop_loss.get_sl(trade.is_buy_trade(),Close[0], trade.is_buy_trade()?Low[1]:High[1]);
            double new_tp=take_profit.get_tp(trade.is_buy_trade(),new_sl,Close[0]);
            if(new_sl>0)
               trade.edit_sl(new_sl);
            if(new_tp>0)
               trade.edit_tp(new_tp);
         }
         check_for_close(rsi1[best_index],iCustom(Symbol(), Period(),"myIndicators/schmittRSI", RSI_len[best_index], schmitt_threshold, 0,2));
      }
      if(!trade.have_open_trade())
         check_for_open(best_index, rsi1[best_index]
            ,iCustom(Symbol(), Period(),"myIndicators/schmittRSI", RSI_len[best_index], schmitt_threshold, 0,2)
            ,iCustom(Symbol(), Period(),"myIndicators/schmittRSI", RSI_len[best_index], schmitt_threshold, 0,3));
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
