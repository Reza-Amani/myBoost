//+------------------------------------------------------------------+
//|                                               history_search.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs

#include <MyHeaders\MyMath.mqh>
#include <MyHeaders\Pattern.mqh>
#include <MyHeaders\ExamineBar.mqh>
#include <MyHeaders\Screen.mqh>
#include <MyHeaders\Tools.mqh>


input int      pattern_len=12;
input int      correlation_thresh=90;
input int      thresh_hC=30;  
            //30 means: 2*0.65-1
input int      thresh_aC=40;
input int      min_hit=25;
input int      max_hit=100;
input CorrelationBase correlation_base=CORREL_HLS;
input ConcludeCriterion criterion=USE_HH1;
input int      bars_to_search=3000;
input int      lookback_len=3000;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Screen screen;
   screen.add_L1_comment("script started-");
   int outfilehandle=FileOpen("./trydata/go_through_history_"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');
   if(outfilehandle<0)
     {
      screen.add_L1_comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return;
     }
   screen.add_L1_comment("file ok-");
   if(Bars<lookback_len+bars_to_search)
   {
      Print("Not enough history");
      screen.add_L1_comment("short history");
      return;
   }
   screen.add_L1_comment("-in"+IntegerToString(lookback_len)+"for"+IntegerToString(bars_to_search));

   Pattern* p_pattern;
   ExamineBar* p_bar;
   Pattern moving_pattern;
      
   int output_counter=0;
   for(int _ref=10;_ref<bars_to_search;_ref++)
   {
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
