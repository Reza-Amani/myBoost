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

///////////////////////////////inputs
input int NRSI_len=13;
input int t_spread=20;
input double smooth_factor=0.1;
input double   lots_base = 1;
input bool ECN = false;

double lots =  lots_base;
double nrsi0,nrsi1,nrsi2;
//////////////////////////////parameters
//////////////////////////////objects
Screen screen;
TradeControl trade(ECN);

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open()
{
   if(nrsi2<=nrsi1 && nrsi1>nrsi0)
      trade.sell(lots,0,0);
   if(nrsi2>=nrsi1 && nrsi1<nrsi0)
      trade.buy(lots,0,0);
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
      
      nrsi0 = iCustom(Symbol(), Period(),"myIndicators/NRSI", NRSI_len, t_spread, smooth_factor, 1,0); 
      nrsi1 = iCustom(Symbol(), Period(),"myIndicators/NRSI", NRSI_len, t_spread, smooth_factor, 1,1); 
      nrsi2 = iCustom(Symbol(), Period(),"myIndicators/NRSI", NRSI_len, t_spread, smooth_factor, 1,2); 

//      screen.clear_L5_comment();
//      screen.add_L5_comment("macd "+DoubleToString(macd_macd)+"sig "+DoubleToString(macd_sig_ma)+"force "+DoubleToString(macd_force)+"dforce "+DoubleToString(macd_dforce));
      
//      screen.clear_L1_comment();
//      screen.add_L1_comment("bars:"+IntegerToString(bars));
      
      if(trade.have_open_trade())
      {
         check_for_close();
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
