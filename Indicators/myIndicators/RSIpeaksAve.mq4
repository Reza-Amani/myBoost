//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <MyHeaders\MyMath.mqh>

#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5
#property indicator_maximum 100
#property indicator_minimum 0
#property indicator_level1  30
#property indicator_level2  70
//--- indicator buffers
double         Buffer_RSI[];
double         Buffer_peak_follower[];
double         Buffer_valey_follower[];
double         Buffer_peak_ave[];
double         Buffer_valey_ave[];
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
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrRed);
   SetIndexBuffer(0,Buffer_RSI);
   SetIndexLabel(0 ,"RSI");   
   SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 1, clrDarkCyan);
   SetIndexBuffer(1,Buffer_peak_follower);
   SetIndexLabel(1,"peaks");   
   SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 1, clrDarkGoldenrod);
   SetIndexBuffer(2,Buffer_valey_follower);
   SetIndexLabel(2,"valeys");   
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, clrAqua);
   SetIndexBuffer(3,Buffer_peak_ave);
   SetIndexLabel(3,"peaks ave");   
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, clrBlueViolet);
   SetIndexBuffer(4,Buffer_valey_ave);
   SetIndexLabel(4,"valeys ave");   
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
      Buffer_peak_follower[limit]=51;
      Buffer_valey_follower[limit]=49;
      limit--;  // to avoid the array out of range problem when counted_bars==0
   }
//   else //--- the indicator has been already calculated, counted_bars>0
//      limit++;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
   
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double rsi0 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,i+0);  
//      double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,i+1);  
      
      Buffer_RSI[i]=rsi0;
      Buffer_peak_follower[i]=math.max(Buffer_peak_follower[i+1]-1,rsi0,51);
      Buffer_valey_follower[i]=math.min(Buffer_valey_follower[i+1]+1,rsi0,49);
      
      if(i<Bars-1-filter_len)
      {
         Buffer_peak_ave[i]=iMAOnArray(Buffer_peak_follower,0,filter_len,0,MODE_LWMA,i);
         Buffer_valey_ave[i]=iMAOnArray(Buffer_valey_follower,0,filter_len,0,MODE_LWMA,i);
      }
      else
      {
         Buffer_peak_ave[i]=52;
         Buffer_valey_ave[i]=48;
      }
      
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
