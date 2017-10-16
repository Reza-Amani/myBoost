//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_level1 0
#property indicator_buffers 6
#property indicator_plots   6
#property indicator_maximum +5
#property indicator_minimum -5

#include <MyHeaders\Operations\PeakEater.mqh>
#include <MyHeaders\Crits\CritPeakDigester.mqh>
#include <MyHeaders\Crits\CritParabolicLover.mqh>
#include <MyHeaders\Crits\CritPeakOrderer.mqh>
#include <MyHeaders\Crits\CritPeakQuality.mqh>
#include <MyHeaders\Crits\CritRelativeVolatility.mqh>
#include <MyHeaders\Crits\CritPeakSimple.mqh>

//--- indicator buffers
double         Buffer_digester[];
double         Buffer_parabolic[];
double         Buffer_orderer[];
double         Buffer_quality[];
double         Buffer_volatility[];
double         Buffer_simple[];
//-----------------inputs
input bool for_buy=true;
input int RSI_len=28;
input bool fast_peak=true;
//-----------------macros
PeakEater peaks(fast_peak);
PeakDigester digester(1);
ParabolicLover parabol(1,0.01,0.2);
PeakOrderer orderer(1);
PeakQuality peak_quality(1);
RelativeVolatility volatility(1,100);
PeakSimple simple(1);
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
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, clrRed);
   SetIndexBuffer(5,Buffer_simple);
   SetIndexLabel(5 ,"simple");   
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
      limit-=2;  // to avoid the array out of range problem when counted_bars==0
   }
   else //--- the indicator has been already calculated, counted_bars>0
      limit--;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
   
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len ,0,i+0); 
      PeakEaterResult peaks_return;
      double new_peak;
      peaks_return = peaks.take_sample(rsi1,new_peak);
      
      //-----------------------------------------------------------------------------------------------------------------charging Crits
      digester.take_input(peaks_return,new_peak,rsi1);
      parabol.take_input(i);
      orderer.take_input(new_peak ,peaks.V0,peaks.V1,peaks.V2,peaks.A0,peaks.A1,peaks.A2);
      volatility.take_input();
      peak_quality.take_input(new_peak ,peaks.V0,peaks.V1,peaks.V2,peaks.A0,peaks.A1,peaks.A2);
      simple.take_input(new_peak ,peaks.V0,peaks.V1,peaks.V2,peaks.A0,peaks.A1,peaks.A2);
      
/*      Buffer_digester[i]=parabol.signed_advice(parabol.get_advice(for_buy,i));
      Buffer_parabolic[i]=parabol.signed_advice(parabol.get_advice(for_buy,i));
      Buffer_orderer[i]=parabol.signed_advice(parabol.get_advice(for_buy,i));
      Buffer_volatility[i]=parabol.signed_advice(parabol.get_advice(for_buy,i));
      Buffer_quality[i]=parabol.signed_advice(parabol.get_advice(for_buy,i));
*/
      Buffer_digester[i]=digester.signed_advice(digester.get_advice(for_buy));
      Buffer_parabolic[i]=parabol.signed_advice(parabol.get_advice(for_buy,i));
      Buffer_orderer[i]=orderer.signed_advice(orderer.get_advice(for_buy));
      Buffer_volatility[i]=volatility.signed_advice(volatility.get_advice(for_buy));
      Buffer_quality[i]=peak_quality.signed_advice(peak_quality.get_advice(for_buy));
      Buffer_simple[i]=simple.signed_advice(peak_quality.get_advice(for_buy));

   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
