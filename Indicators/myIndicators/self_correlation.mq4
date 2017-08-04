//+------------------------------------------------------------------+
//|                                             self_correlation.mq4 |
//|                                                             Reza |
//|                                                                  |
//+------------------------------------------------------------------+
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
input int      pattern_len = 20;
input int      ref_offset = 10;
input int      history_len = 100;
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
/*      limit = rates_total - prev_calculated; //for excluding prev calculated bars
      if(prev_calculated>0)
         limit++;
*/
      limit = history_len;       //running only on a last part of chart
      for(int i=limit-1; i >= 0; i--)
      {
         Buffer_bar_no[i]= i;
       }
    }

   return(rates_total);
  }
//+------------------------------------------------------------------+
