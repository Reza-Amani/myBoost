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
#include <MyHeaders\BarTrain.mqh>

///////////////////////////////inputs
input AlgoOpen algo;
input AlgoClose algo_close;
input int algo_par0=0;
input int algo_par1=0;
input int algo_par2=0;
input int long_filter=100;
input int short_filter=10;
input double threshold_short=0.1;
input double threshold_long=0.1;
input bool check_keep_position=true;
input bool use_history=true;
input bool use_sl_tp=true;
input double sl_factor=2;
input double tp_factor=2;
input double   lots_base = 1;
input bool ECN = false;

double lots =  lots_base;
//////////////////////////////parameters
//////////////////////////////objects
BarTrain bar(long_filter,short_filter, algo, algo_close, threshold_short, threshold_long); 
Screen screen;
TradeControl trade(ECN);
MyMath math;
StopLoss sl((use_sl_tp)?SL_BARSIZE:SL_NONE, sl_factor, 0);
/*
MoneyManagement money(lots_base);
TakeProfit take_profit(tp_factor_sl);
*/
int file_handle=FileOpen("./tradefiles/T"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_rule"+EnumToString(algo)+".csv",FILE_WRITE|FILE_CSV,',');
#define cont    FileSeek(file_handle,-2,SEEK_CUR)

//+------------------------------------------------------------------+
//| operation                                                        |
//+------------------------------------------------------------------+
void check_for_open()
{
   double sl_buy=sl.get_sl(true, Open[0], bar.ave_barsize, 0);
   double sl_sell=sl.get_sl(false, Open[0], bar.ave_barsize, 0);
   double weight=0;

   lots = lot_manager(lots_base, false, 1, 0);
   int signal = bar.GetSignal(0,TrainDepth,weight,algo_par0,algo_par1,algo_par2);
   if(signal==1)
      trade.buy(lots,sl_buy,0);
   else if(signal==-1)
      trade.sell(lots,sl_sell,0);
}
void  check_for_close()
{  //TODO: check against the current depth stat to keep
   bool buy_trade=trade.is_buy_trade();
   if(!bar.IsKeepable())
      trade.close();
}

double lot_manager(double _lot_base, bool _use_quality, double _hope, double _magic_no)
{
   double lot_result=0;
   lot_result = _lot_base*(1+_magic_no*0.1);
   if(_use_quality)
      lot_result *= math.abs(_hope);
   return lot_result;
}
void OSD()
{
   string trade_report=trade.get_report();
   if(trade_report!="")
   {
      trade.clear_report();
      screen.clear_L2_comment();
      screen.add_L2_comment(trade_report);
      Print(trade_report);
   }
   screen.clear_L3_comment();
   screen.add_L3_comment("spread= "+IntegerToString((Ask-Bid)*100000));
   screen.add_L3_comment(" filters: ");
   for(int i=0; i<TrainDepth; i++)
      screen.add_L3_comment(IntegerToString(i)+"         ");

   screen.clear_L5_comment();
   screen.add_L5_comment("p=0,SH/LO=      ");
   for(int i=0; i<TrainDepth; i++)
   {
      screen.add_L5_comment("  "+IntegerToString(100*bar.short_stat[i][0],2));
      screen.add_L5_comment("/"+IntegerToString(100*bar.long_stat[i][0],2));
   }
   screen.clear_L6_comment();
   screen.add_L6_comment("p=1,SH/LO=      ");
   for(int i=0; i<TrainDepth; i++)
   {
      screen.add_L6_comment("  "+IntegerToString(100*bar.short_stat[i][1],2));
      screen.add_L6_comment("/"+IntegerToString(100*bar.long_stat[i][1],2));
   }
}
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
   
   FileWrite(file_handle,"Bar","cprice","S0-0","L0-0","S0-1","L0-1",
      "S1-0","L1-0","S1-1","L1-1",
      "S2-0","L2-0","S2-1","L2-1",
      "S3-0","L3-0","S3-1","L3-1",
      "S4-0","L4-0","S4-1","L4-1");

   int history_bars = math.min(Bars, 1000) - 3 -10; //-10 is just in case, as a marging for future development
   if(use_history && history_bars>10)
   {
      for(int i=history_bars; i>0; i--)
         bar.NewData(Open[i], Close[i], High[i], Low[i]);
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

//      cont;      
//      FileWrite(file_handle,"", Close[1]-Open[1]);

      bar.NewData(Open[1], Close[1], High[1], Low[1]);
   
      FileWrite(file_handle,bars,Close[1],"");
      cont;
      for(int i=0; i<TrainDepth; i++)
         for(int p=0; p<2; p++)
         {
            FileWrite(file_handle, bar.short_stat[i][p], bar.long_stat[i][p],"");
            cont;
         }
      FileWrite(file_handle, 0);
      
      if(trade.have_open_trade())
         check_for_close();
      //if(trade.have_open_trade())
         //TODO: update sl tp if not closed
      if(!trade.have_open_trade())
         check_for_open();
         
      OSD();
   }
}
//+------------------------------------------------------------------+
