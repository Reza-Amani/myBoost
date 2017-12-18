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
input int schmitt_threshold=4;
input int  simpler_thresh=30;
//-----------------macros
#define SARS   3
int RSI_len[6]={20,28,40,56,80,112};

PeakEater * peaks[SARS];
PeakSimple * simple_crit[SARS];

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

   for(int i=0; i<SARS;i++)
      simple_crit[i] = new PeakSimple(simpler_thresh,1,true,ave_len);
   for(int i=0; i<SARS;i++)
      peaks[i] = new PeakEater();

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
      double rsi1[SARS];
      for(int j=0; j<SARS;j++)
         rsi1[j] = iCustom(Symbol(), Period(),"myIndicators/schmittRSI", RSI_len[j], schmitt_threshold, 0,i+0); 
      
      for(int j=0; j<SARS;j++)
         peaks[j].take_sample(rsi1[j]);
      
      for(int j=0; j<SARS;j++)
         simple_crit[j].take_input(peaks[j].V0,peaks[j].V1,peaks[j].V2,peaks[j].A0,peaks[j].A1,peaks[j].A2);
      
      Buffer_RSI_0[i]=rsi1[0];
      Buffer_RSI_1[i]=rsi1[1];
      Buffer_RSI_2[i]=rsi1[2];
      
      Buffer_mood_0[i]=simple_crit[0].get_mood(rsi1[0],peaks[0].is_rising());
      Buffer_mood_1[i]=simple_crit[1].get_mood(rsi1[1],peaks[1].is_rising());
      Buffer_mood_2[i]=simple_crit[2].get_mood(rsi1[2],peaks[2].is_rising());
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
