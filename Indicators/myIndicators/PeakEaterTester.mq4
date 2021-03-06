//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_level1 50
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_maximum 100
#property indicator_minimum 0

#include <MyHeaders\Operations\PeakEater.mqh>

//--- indicator buffers
double         Buffer_events[];
//-----------------inputs
input int RSI_len=28;
//-----------------macros
PeakEater peaks();
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(0,Buffer_events);
   SetIndexLabel(0 ,"events");   
//---
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
   //--- the number of bars that have not changed since the last indicator call
   int counted_bars=IndicatorCounted();
   //--- exit if an error has occurred
   if(counted_bars<0) return(-1);
      
   //--- position of the bar from which calculation in the loop starts
   int limit=Bars-counted_bars;

   //--- if counted_bars=0, reduce the starting position in the loop by 1,   
   if(counted_bars==0) 
   {
      limit--;  // to avoid the array out of range problem when counted_bars==0
   }
   else //--- the indicator has been already calculated, counted_bars>0
      limit++;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
   
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,i+0); 
      
      PeakEaterResult peaks_return;
      peaks_return = peaks.take_sample(rsi1);

      switch(peaks_return)
      {
         case RESULT_CONFIRM_A:
            Buffer_events[i] = 90;
            break;
         case RESULT_CONFIRM_V:
            Buffer_events[i] = 10;
            break;
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
