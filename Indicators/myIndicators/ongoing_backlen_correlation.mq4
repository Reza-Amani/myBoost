//+------------------------------------------------------------------+
//|                                             self_correlation.mq4 |
//|                                                             Reza |
//|                                                                  |
//+------------------------------------------------------------------+
#include <MyHeaders\Pattern.mqh>
#property copyright "Reza"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100

#property indicator_buffers 2
#property indicator_plots   1
//--- indicator buffers
double         Buffer_correl[];
double         Buffer_bar_no[];
//--- input parameters
input int      pattern_len = 50;
input int      history_len = 1000;
//vars
datetime    _last_open_time;
int limit;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrBlue);
   SetIndexBuffer(0,Buffer_correl);
   SetIndexLabel(0 ,"self correlation");   
   
   SetIndexStyle(1, DRAW_NONE, STYLE_SOLID, 1, clrBlue);
   SetIndexBuffer(1,Buffer_bar_no);
   SetIndexLabel(1 ,"bar no");   

   _last_open_time=0;
   limit = 0;
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(_last_open_time != time[0])   //for running only at the open tick
   {
      _last_open_time = time[0];
      limit = MyMath::min(rates_total - prev_calculated , history_len); //for excluding prev calculated bars
      if(prev_calculated>0)
         limit++;

//      limit = history_len;       //running only on a last part of chart
      for(int i=limit-1; i >= 0; i--)
      {
         Buffer_bar_no[i]= i;
      }
      
      Pattern ref_pattern,moving_pattern;
      
      for(int i=limit-1; i >= 0; i--)
      {
         ref_pattern.set_data(High, Low, Close, i, pattern_len,0,0,0, CORREL_CLOSE);
         moving_pattern.set_data(High, Low, Close, i+pattern_len, pattern_len,0,0,0, CORREL_CLOSE);
         Buffer_correl[i]= ref_pattern && moving_pattern;
      }
      
    }

   return(rates_total);
  }
//+------------------------------------------------------------------+
