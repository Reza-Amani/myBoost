//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <MyHeaders\MyMath.mqh>

#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_maximum 100
#property indicator_minimum 0
#property indicator_level1  30
#property indicator_level2  70
//--- indicator buffers
double         Buffer_rsi[];
double         Buffer_peak_detector[];
double         Buffer_raw_score[];
double         Buffer_smoothdrop_score[];
//-----------------macros
//-----------------inputs
input int RSI_len=14;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrDarkBlue);
   SetIndexBuffer(0,Buffer_rsi);
   SetIndexLabel(0 ,"rsi");   
   SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 1, clrDarkGray);
   SetIndexBuffer(1,Buffer_peak_detector);
   SetIndexLabel(1 ,"last peak");   
   SetIndexStyle(2, DRAW_LINE, STYLE_DASH, 1, clrDarkRed);
   SetIndexBuffer(2,Buffer_raw_score);
   SetIndexLabel(2 ,"raw score");   
   SetIndexStyle(3, DRAW_LINE, STYLE_DASHDOT, 1, clrDarkOrange);
   SetIndexBuffer(3,Buffer_smoothdrop_score);
   SetIndexLabel(3 ,"smoothed drop");   
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
      Buffer_peak_detector[Bars-1]=50;
      Buffer_raw_score[Bars-1]=0;
      Buffer_raw_score[Bars-2]=0;
      Buffer_smoothdrop_score[Bars-1]=0;
      Buffer_smoothdrop_score[Bars-2]=0;
      
      limit--;  
      limit--;  
   }
//   else //--- the indicator has been already calculated, counted_bars>0
//      limit++;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
   
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double rsi1 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,1+i);
      double rsi2 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,2+i);
      double rsi3 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,3+i);
      double rsi4 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,4+i);
      double rsi5 = iCustom(Symbol(), Period(),"myIndicators/scaledRSI", RSI_len, 0,5+i);
      Buffer_rsi[i]=rsi3;
      Buffer_peak_detector[i]=Buffer_peak_detector[i+1];
      Buffer_raw_score[i]=Buffer_raw_score[i+1];
      if(rsi3>=math.max(rsi1,rsi2,rsi4,rsi5) || rsi3<=math.min(rsi1,rsi2,rsi4,rsi5) )  // a peak detected
         if( !( (rsi3>70 && Buffer_peak_detector[i+1]>70) ||  (rsi3<30 && Buffer_peak_detector[i+1]<30) ) ) // exclude any return at over-bought/oversold area
            Buffer_peak_detector[i]=rsi3;
            
      double peak_change = Buffer_peak_detector[i] - Buffer_peak_detector[i+1];
      double temp_score = (rsi1-Buffer_peak_detector[i]) * math.sign(rsi1-rsi2);
      if( temp_score >= 0)
         Buffer_raw_score[i] = math.abs(rsi1-Buffer_peak_detector[i]);
      else
         Buffer_raw_score[i]=0;
      if(rsi1==99 || rsi1==1)
         Buffer_raw_score[i]=math.max(Buffer_raw_score[i],Buffer_raw_score[i+1],Buffer_raw_score[i+2]);
      Buffer_smoothdrop_score[i]=math.max(Buffer_smoothdrop_score[i+1]-3,Buffer_raw_score[i],0);
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
