//+------------------------------------------------------------------+
//|                                               PredEvaluating.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs

#include <MyHeaders\Tools\MyMath.mqh>
//#include <MyHeaders\Pattern.mqh>
//#/include <MyHeaders\ExamineBar.mqh>
#include <MyHeaders\Tools\Screen.mqh>
#include <MyHeaders\Tools\Tools.mqh>

input int InpFastEMA=12;   // Fast EMA Period
input int InpSignalSMA=9;  // Signal SMA Period
input int      bars_to_search=3000;

#define cont    FileSeek(file_handle,-2,SEEK_CUR)

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Screen screen;
   screen.add_L1_comment("script started-");
   int file_handle=FileOpen("./preddata/pred_"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(InpFastEMA)+"_"+IntegerToString(InpSignalSMA)+".csv",FILE_WRITE|FILE_CSV,',');
   if(file_handle<0)
     {
      screen.add_L1_comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return;
     }
   screen.add_L1_comment("file ok-");
   if(Bars<bars_to_search)
   {
      Print("Not enough history");
      screen.add_L1_comment("short history");
      return;
   }
   screen.add_L1_comment("-for "+IntegerToString(bars_to_search));

   int output_counter=0;
   for(int _ref=1;_ref<bars_to_search-InpFastEMA-InpSignalSMA;_ref++)
   {
      double   macd_macd = iCustom(Symbol(), Period(),"myIndicators/myMACD", InpFastEMA, InpSignalSMA, 0,_ref); 
      double   macd_sig_ma = iCustom(Symbol(), Period(),"myIndicators/myMACD", InpFastEMA, InpSignalSMA, 1,_ref); 
      double   macd_force = iCustom(Symbol(), Period(),"myIndicators/myMACD", InpFastEMA, InpSignalSMA, 2,_ref); 
      double   macd_dforce = iCustom(Symbol(), Period(),"myIndicators/myMACD", InpFastEMA, InpSignalSMA, 3,_ref); 
      
      double open_price = Close[_ref];
      double close_price = Close[_ref-1];
      double price_change = close_price - open_price;
      
      FileWrite(file_handle,"Bar",_ref);
      cont;
      FileWrite(file_handle,"","macd",macd_macd);
      cont;
      FileWrite(file_handle,"","sig_ma",macd_sig_ma);
      cont;
      FileWrite(file_handle,"","force",macd_force);
      cont;
      FileWrite(file_handle,"","dforce",macd_dforce);

      cont;
      FileWrite(file_handle,"","oprice",open_price);
      cont;
      FileWrite(file_handle,"","change",price_change);

      screen.clear_L2_comment();
      screen.add_L2_comment("output:"+IntegerToString(output_counter));
      screen.clear_L3_comment();
      screen.add_L3_comment("counter:"+IntegerToString(_ref));
      
   }
}
//+------------------------------------------------------------------+
/*
void ExamineBar::log_to_file_common(int file_handle)
{
   cont;
   FileWrite(file_handle,"","Bar",barno);
   cont;
   FileWrite(file_handle,"","hits",number_of_hits);
//   cont;
//   if(number_of_hits!=0)
//      FileWrite(file_handle,"","aveaC1",sum_ac1/number_of_hits);
   cont;
   if(number_of_hits!=0)
      FileWrite(file_handle,"","higherH1",higher_h1,higher_h1/number_of_hits);
   cont;
   if(number_of_hits!=0)
      FileWrite(file_handle,"","SR&direction",potential,direction);
   cont;
   if(number_of_hits!=0)
      FileWrite(file_handle,"","ave_aH1_aL1",ave_aH1,ave_aL1);
   cont;
   pattern.log_to_file(file_handle);

}

void ExamineBar::log_to_file_tester(int file_handle)
{
   if(number_of_hits!=0)
      FileWrite(file_handle,"","Normalised Result-dH1-1/0",direction*(pattern.fh1-pattern.high[0]),(direction*(pattern.fh1-pattern.high[0])>0)?1:0);
}
*/