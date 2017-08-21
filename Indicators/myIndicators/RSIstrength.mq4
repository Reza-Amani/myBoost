//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <MyHeaders\MyMath.mqh>

#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_maximum 100
#property indicator_minimum 0
#property indicator_level1  30
#property indicator_level2  70
//--- indicator buffers
double         Buffer_distance_to_50[];
double         Buffer_smoothed_distance[];
//-----------------macros
//-----------------inputs
input int RSI_len=14;
input int filter_len=50;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 1, clrAqua);
   SetIndexBuffer(0,Buffer_distance_to_50);
   SetIndexLabel(0 ,"gap to 50");   
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, clrYellow);
   SetIndexBuffer(1,Buffer_smoothed_distance);
   SetIndexLabel(1,"filter strength");   
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
      
   MyMath math;

   //--- position of the bar from which calculation in the loop starts
   int limit=Bars-counted_bars;

   //--- if counted_bars=0, reduce the starting position in the loop by 1,   
   if(counted_bars==0) 
   {
      limit--;  // to avoid the array out of range problem when counted_bars==0
      limit--;  // to avoid the array out of range problem when counted_bars==0
      limit--;  // to avoid the array out of range problem when counted_bars==0
      limit--;  // to avoid the array out of range problem when counted_bars==0
   }
//   else //--- the indicator has been already calculated, counted_bars>0
//      limit++;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
   
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double rsi0 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,i+0);  
      double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,i+1);  
      double rsi2 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,i+2);  
      
      Buffer_distance_to_50[i]=math.abs(rsi0-50);
      if( rsi0>rsi1 && rsi1<rsi2 )
      {
         if(rsi1>=70)
            Buffer_distance_to_50[i]= 0;
         else if(rsi1>=40)
            Buffer_distance_to_50[i]= -20;
      }
      else if(rsi0<rsi1 && rsi1>rsi2)
      {
         if(rsi1<=30)
            Buffer_distance_to_50[i]= 0;
         else if(rsi1<=60)
            Buffer_distance_to_50[i]= -20;
      }
      
      if(i<Bars-1-filter_len)
         Buffer_smoothed_distance[i]=iMAOnArray(Buffer_distance_to_50,0,filter_len,0,MODE_LWMA,i);
      else
         Buffer_smoothed_distance[i]=2;
      
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
