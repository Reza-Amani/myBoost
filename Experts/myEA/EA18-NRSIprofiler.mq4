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

//#define _bar_size_filter 10
///////////////////////////////inputs
input int NRSI_len=13;
input int t_spread=20;
input double smooth_factor=0.1;
//input double sl_factor=3;
//input double tp_factor=1;
//input double   lots_base = 1;
//input bool ECN = false;

//double lots =  lots_base;
double nrsi0,nrsi1;
//////////////////////////////parameters
enum BAR_NRSI_STATES
{
   NRSISTATE_NONE,
   NRSISTATE_RISING_MINUS75,
   NRSISTATE_RISING_MINUS75_45,
   NRSISTATE_RISING_MINUS45_15,
   NRSISTATE_RISING_15_15,
   NRSISTATE_RISING_PLUS15_45,
   NRSISTATE_RISING_PLUS45_75,
   NRSISTATE_RISING_PLUS75
};
enum IND_NRSI_STATES
{
   NRSI_RISING,
   NRSI_FALLSING
};
int last_valley=49,last_peak=51; 
IND_NRSI_STATES ind_state=NRSI_RISING;
//////////////////////////////objects
Screen screen;
MyMath math();
//TradeControl trade(ECN);
double ave_bar_size=0;
double last_turn_point=0;
int file_handle=FileOpen("./tradefiles/NSRIp"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+/*"_rule"+EnumToString(algo)+*/".csv",FILE_WRITE|FILE_CSV,',');
#define cont    FileSeek(file_handle,-2,SEEK_CUR)

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open()
{
/*   if(nrsi2==nrsi1 && nrsi1>nrsi0)
      if(nrsi3<nrsi2 || (nrsi3==nrsi2 && nrsi4<nrsi2) || (nrsi3==nrsi2 && nrsi4==nrsi2 && nrsi5<nrsi2))
      {
         last_turn_point=nrsi1;
         if(nrsi0 > last_turn_point+min_clearance)
            trade.sell(lots, Open[0]+sl_factor*ave_bar_size,Open[0]-tp_factor*ave_bar_size);
      }
   if(nrsi2==nrsi1 && nrsi1<nrsi0)
      if(nrsi3>nrsi2 || (nrsi3==nrsi2 && nrsi4>nrsi2) || (nrsi3==nrsi2 && nrsi4==nrsi2 && nrsi5>nrsi2))
      {
         last_turn_point=nrsi1;
         if(nrsi0 < last_turn_point-min_clearance)
            trade.buy(lots,Open[0]-sl_factor*ave_bar_size,Open[0]+tp_factor*ave_bar_size);
      }
   if( (nrsi2<nrsi1 && nrsi1>nrsi0) || (nrsi2>nrsi1 && nrsi1<nrsi0) )
      last_turn_point=nrsi1;
*/
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void  check_for_close()
{  //returns 1 if closes the trade to return to base state
   //0 if the position remains still
/*   bool buy_trade=trade.is_buy_trade();
   if(buy_trade)
   {
      if(nrsi1>nrsi0)
         trade.close();
   }
   else
   {
      if(nrsi1<nrsi0)
         trade.close();
   }
*/
}
//+------------------------------------------------------------------+
//| standard function                                                |
//+------------------------------------------------------------------+
int OnInit()
{
   screen.add_L1_comment("EA started-");
   ave_bar_size=0;
   if(file_handle<0)
   {
      screen.add_L1_comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return(INIT_FAILED);
   }
   else
      screen.add_L1_comment("file ok-");
   
   FileWrite(file_handle,"Bar","cprice","S0-0");

   int history_bars = math.min(Bars, 1000) - 3 -100; //-100 is just in case, as a marging for future development
   if(history_bars>10)
   {
      for(int i=history_bars; i>1; i--)
      {
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
      
      nrsi0 = iCustom(Symbol(), Period(),"myIndicators/NRSI", NRSI_len, t_spread, smooth_factor, 3,0); 
      nrsi1 = iCustom(Symbol(), Period(),"myIndicators/NRSI", NRSI_len, t_spread, smooth_factor, 3,1); 

//      screen.clear_L5_comment();
//      screen.add_L5_comment("macd "+DoubleToString(macd_macd)+"sig "+DoubleToString(macd_sig_ma)+"force "+DoubleToString(macd_force)+"dforce "+DoubleToString(macd_dforce));
      
//      screen.clear_L1_comment();
//      screen.add_L1_comment("bars:"+IntegerToString(bars));
      
/*      if(trade.have_open_trade())
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
*/
   }
}
//+------------------------------------------------------------------+
