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
input double   lots_base = 1;
input bool ECN = false;
input int      schmitt_threshold=4;
input int  simpler_thresh=30;
input int ave_len=3;
input bool set_sl=true;
input double tp_factor_sl=2;
input double   sl_SAR_step=0.01; 
//////////////////////////////parameters
int i;
//////////////////////////////objects
Screen screen;
MyMath math;
MoneyManagement money(lots_base);
StopLoss stop_loss(sl_SAR_step, 0.2);
TakeProfit take_profit(tp_factor_sl);
TradeControl trade(ECN);
PeakEater peaks_0(),peaks_1(),peaks_2();
PeakSimple * simple[3];
//PeakSimple simple[3]={
  // {simpler_thresh,1,true,ave_len},
  // {simpler_thresh,1,true,ave_len},
  // {simpler_thresh,1,true,ave_len}};
//int file=FileOpen("./tradefiles/EAlog.csv",FILE_WRITE|FILE_CSV,',');
//int outfilehandle=FileOpen("./tradefiles/data"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open(PeakEaterResult _peaks_return, double _rsi1)
{
   double SAR_q,volatility_q,simpler_q,total_q;
   switch(open_algo)
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
   
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void  check_for_close()
{  //returns 1 if closes the trade to return to base state
   //0 if the position remains still
   int return_closed=0;

   double rsi1 = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", RSI_len, schmitt_threshold, 0,1); 
   double rsi2 = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", RSI_len, schmitt_threshold, 0,2); 

   bool buy_trade=trade.is_buy_trade();
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
//--------------------------------------------------------------------
int determine_best_index()
{
   
}
//--------------------------------------------------------------------
void process_past_peaks()
{
   int past_bars = (int)math.min(Bars,70);
   for(int i=past_bars; i>0; i--)
   {
      double rsi1 = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", RSI_len, schmitt_threshold, 0,i); 
      peaks.take_sample(rsi1);
   }
   screen.add_L1_comment("past_bars="+IntegerToString(past_bars));
   screen.clear_L5_comment();
   screen.add_L5_comment("past:"+peaks.get_report());
}
//+------------------------------------------------------------------+
//| standard function                                                |
//+------------------------------------------------------------------+
int OnInit()
{
   for( i=0; i<no_of_sars;i++)
      simple[i] = new PeakSimple(simpler_thresh,1,true,ave_len);
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
   if(IsTradeAllowed()==false)
      return;
   static int bars=0, best_index=0;
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
      
      double rsi1[3];
      rsi1[0] = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", 25, schmitt_threshold, 0,1); 
      rsi1[1] = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", 35, schmitt_threshold, 0,1); 
      rsi1[2] = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", 50, schmitt_threshold, 0,1); 
      
      peaks_0.take_sample(rsi1[0]);
      peaks_1.take_sample(rsi1[0]);
      peaks_2.take_sample(rsi1[0]);
      
      simple_0.take_input(peaks_0.V0,peaks_0.V1,peaks_0.V2,peaks_0.A0,peaks_0.A1,peaks_0.A2);
      simple_1.take_input(peaks_1.V0,peaks_1.V1,peaks_1.V2,peaks_1.A0,peaks_1.A1,peaks_1.A2);
      simple_2.take_input(peaks_2.V0,peaks_2.V1,peaks_2.V2,peaks_2.A0,peaks_2.A1,peaks_2.A2);
      
      screen.clear_L5_comment();
      screen.add_L5_comment(peaks.get_report());
      
      screen.clear_L1_comment();
      screen.add_L1_comment("bars:"+IntegerToString(bars));
      
      best_index = determine_best_index();
      if(trade.have_open_trade())
      {
         double new_sl=stop_loss.get_sl(trade.is_buy_trade(),Close[0], trade.is_buy_trade()?Low[1]:High[1]);
         double new_tp=take_profit.get_tp(trade.is_buy_trade(),new_sl,Close[0]);
         if(new_sl>0)
            trade.edit_sl(new_sl);
         if(new_tp>0)
            trade.edit_tp(new_tp);
         check_for_close();
      }
      if(!trade.have_open_trade())
         check_for_open(peaks_return,rsi1);
            
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
