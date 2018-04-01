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

#include <MyHeaders\MyMath.mqh>
//#include <MyHeaders\Pattern.mqh>
//#/include <MyHeaders\ExamineBar.mqh>
#include <MyHeaders\Screen.mqh>
#include <MyHeaders\Tools.mqh>

input int InpFastEMA=12;   // Fast EMA Period
input int InpSignalSMA=9;  // Signal SMA Period
input int      bars_to_search=3000;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Screen screen;
   screen.add_L1_comment("script started-");
   int outfilehandle=FileOpen("./preddata/pred_"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(InpFastEMA)+"_"+IntegerToString(InpSignalSMA)+".csv",FILE_WRITE|FILE_CSV,',');
   if(outfilehandle<0)
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
      
      double open_price = Open[_ref];
      double close_price = Open[_ref-1];
      double price_change = close_price - open_price;
      
      

      p_pattern=new Pattern(High,Low,Close,_ref,pattern_len,Close[_ref-1],High[_ref-1],Low[_ref-1],correlation_base);
      
      p_bar=new ExamineBar(_ref,p_pattern);
     
      for(int j=10+_ref;j<_ref+lookback_len-pattern_len;j++)
      {
         moving_pattern.set_data(High,Low,Close,j,pattern_len,Close[j-1],High[j-1],Low[j-1],correlation_base);
         if(p_bar.check_another_bar(moving_pattern,correlation_thresh,max_hit))
            break;
      }
      if(p_bar.conclude(criterion,min_hit,thresh_hC,thresh_aC))
      {  //a famous and good bar!
         p_bar.log_to_file_tester(outfilehandle);
         p_bar.log_to_file_common(outfilehandle);
         output_counter++;
      }
      
      screen.clear_L2_comment();
      screen.add_L2_comment("output:"+IntegerToString(output_counter));
      screen.clear_L3_comment();
      screen.add_L3_comment("counter:"+IntegerToString(_ref));
            
      
      delete p_bar;
      delete p_pattern;
   }

}
//+------------------------------------------------------------------+
