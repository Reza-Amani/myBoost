//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_level1 15
#property indicator_buffers 6
#property indicator_plots   6
#property indicator_maximum 100
#property indicator_minimum 0

#include <MyHeaders\Operations\PeakEater.mqh>
#include <MyHeaders\Crits\CritPeakSimple.mqh>

//--- indicator buffers
double         Buffer_RSI_0[];
double         Buffer_RSI_1[];
double         Buffer_RSI_2[];
double         Buffer_mood_0[];
double         Buffer_mood_1[];
double         Buffer_mood_2[];
//-----------------inputs
input int ave_len=2;
input int  simpler_thresh=30;
//-----------------macros
PeakEater peaks_0(),peaks_1(),peaks_2();
PeakSimple simple_0(simpler_thresh,1,true,ave_len);
PeakSimple simple_1(simpler_thresh,1,true,ave_len);
PeakSimple simple_2(simpler_thresh,1,true,ave_len);
MyMath math;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_DASH, 5, clrRed);
   SetIndexBuffer(0,Buffer_mood_0);
   SetIndexLabel(0 ,"mood0");   
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_DASHDOT, 2, clrDarkOrange);
   SetIndexBuffer(1,Buffer_mood_1);
   SetIndexLabel(1 ,"mood1");   
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_DASHDOTDOT, 1, clrYellow);
   SetIndexBuffer(2,Buffer_mood_2);
   SetIndexLabel(2 ,"mood2");   

   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, clrRed);
   SetIndexBuffer(3,Buffer_RSI_0);
   SetIndexLabel(3 ,"simple0");   
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, clrDarkOrange);
   SetIndexBuffer(4,Buffer_RSI_1);
   SetIndexLabel(4 ,"simple1");   
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, clrYellow);
   SetIndexBuffer(5,Buffer_RSI_2);
   SetIndexLabel(5 ,"simple2");   
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
      double rsi_0_1 = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", 25, 4, 0,i+0); 
      double rsi_1_1 = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", 35, 4, 0,i+0); 
      double rsi_2_1 = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", 50, 4, 0,i+0); 
      peaks_0.take_sample(rsi_0_1);
      peaks_1.take_sample(rsi_1_1);
      peaks_2.take_sample(rsi_2_1);
      
      //-----------------------------------------------------------------------------------------------------------------charging Crits
      simple_0.take_input(peaks_0.V0,peaks_0.V1,peaks_0.V2,peaks_0.A0,peaks_0.A1,peaks_0.A2);
      simple_1.take_input(peaks_1.V0,peaks_1.V1,peaks_1.V2,peaks_1.A0,peaks_1.A1,peaks_1.A2);
      simple_2.take_input(peaks_2.V0,peaks_2.V1,peaks_2.V2,peaks_2.A0,peaks_2.A1,peaks_2.A2);
      
      Buffer_RSI_0[i]=rsi_0_1;
      Buffer_RSI_1[i]=rsi_1_1;
      Buffer_RSI_2[i]=rsi_2_1;
      
      Buffer_mood_0[i]=simple_0.get_mood(rsi_0_1,peaks_0.is_rising());
      Buffer_mood_1[i]=simple_1.get_mood(rsi_1_1,peaks_1.is_rising());
      Buffer_mood_2[i]=simple_2.get_mood(rsi_2_1,peaks_2.is_rising());
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
