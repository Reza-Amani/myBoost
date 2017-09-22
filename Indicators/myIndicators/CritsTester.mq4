//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_level1 0
#property indicator_buffers 5
#property indicator_plots   5
#property indicator_maximum +5
#property indicator_minimum -5

#include <MyHeaders\Operations\PeakEater.mqh>
#include <MyHeaders\Crits\CritPeakDigester.mqh>
#include <MyHeaders\Crits\CritParabolicLover.mqh>
#include <MyHeaders\Crits\CritPeakOrderer.mqh>
#include <MyHeaders\Crits\CritPeakQuality.mqh>
#include <MyHeaders\Crits\CritRelativeVolatility.mqh>

//--- indicator buffers
double         Buffer_digester[];
double         Buffer_parabolic[];
double         Buffer_orderer[];
double         Buffer_quality[];
double         Buffer_volatility[];
//-----------------macros
PeakEater peaks();
PeakDigester digester(1);
ParabolicLover parabol(1,0.01,0.2);
PeakOrderer orderer(1);
PeakQuality peak_quality(1);
RelativeVolatility volatility(1,100);
//-----------------inputs
input int RSI_len=28;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(0,Buffer_digester);
   SetIndexLabel(0 ,"digester");   
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, clrBeige);
   SetIndexBuffer(1,Buffer_orderer);
   SetIndexLabel(1 ,"orderer");   
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, clrOrange);
   SetIndexBuffer(2,Buffer_parabolic);
   SetIndexLabel(2 ,"parabolic");   
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, clrBlue);
   SetIndexBuffer(3,Buffer_quality);
   SetIndexLabel(3 ,"quality");   
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, clrOlive);
   SetIndexBuffer(4,Buffer_volatility);
   SetIndexLabel(4 ,"volatility");   
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
//   else //--- the indicator has been already calculated, counted_bars>0
//      limit++;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
   
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,i+0); 
      PeakEaterResult peaks_return;
      double new_peak;
      peaks_return = peaks.take_sample(rsi1,new_peak);
      
      //-----------------------------------------------------------------------------------------------------------------charging Crits
      digester.take_input(peaks_return,new_peak,rsi1);
      parabol.take_input();
      orderer.take_input(new_peak ,peaks.V0,peaks.V1,peaks.V2,peaks.A0,peaks.A1,peaks.A2);
      volatility.take_input();
      peak_quality.take_input(new_peak ,peaks.V0,peaks.V1,peaks.V2,peaks.A0,peaks.A1,peaks.A2);
      
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
