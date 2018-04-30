//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_level1 0
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_maximum 100
#property indicator_minimum -100

#include <MyHeaders\Tools\MyMath.mqh>
MyMath math;
//--- indicator buffers
double         Buffer_NRSI[];
double         Buffer_smoothed[];
double         Buffer_Hthresh[];
double         Buffer_Lthresh[];
//-----------------inputs
input int NRSI_len=10;
input int t_spread=20;
input double smooth_factor=0.1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(0,Buffer_NRSI);
   SetIndexLabel(0 ,"NRSI");   
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, clrDarkBlue);
   SetIndexBuffer(1,Buffer_Hthresh);
   SetIndexLabel(1 ,"H");   
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, clrDarkBlue);
   SetIndexBuffer(2,Buffer_Lthresh);
   SetIndexLabel(2 ,"L");   
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, clrYellow);
   SetIndexBuffer(3,Buffer_smoothed);
   SetIndexLabel(3 ,"smoothed");   
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
   int limit=Bars-counted_bars-1;

   //--- if counted_bars=0, reduce the starting position in the loop by 1,   
   if(counted_bars==0) 
   {
      limit-=NRSI_len+2;  // to avoid the array out of range problem when counted_bars==0
      Buffer_NRSI[limit+1]=0;
      Buffer_Hthresh[limit+1]=0;
      Buffer_Lthresh[limit+1]=0;
   }
//   else //--- the indicator has been already calculated, counted_bars>0
  //    limit++;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
  
   //--- the main calculation loop
   double pos_bars,neg_bars;
   double diff;
   for (int i=limit; i>=0; i--)
   {
      pos_bars=DBL_MIN;
      neg_bars=DBL_MIN;
      for(int j=0; j<NRSI_len; j++)
      {
         diff = (Open[i+j+1]+Close[i+j+1]+High[i+j+1]+Low[i+j+1])/4-(Open[i+j+2]+Close[i+j+2]+High[i+j+2]+Low[i+j+2])/4;
         if(diff>0)
            pos_bars += diff*(NRSI_len-j);
         else
            neg_bars -= diff*(NRSI_len-j);
      }
      Buffer_NRSI[i] = 100 * (pos_bars-neg_bars) / (pos_bars+neg_bars);
      double p1=0;
      double p2=0;
      if(math.sign(Close[i+1]-Open[i+1])*math.sign(Close[i+2]-Open[i+2]) == -1)
      {
         p1=2*smooth_factor;
         p2=smooth_factor;
      }
      else if(math.sign(Close[i+1]-Open[i+1])*math.sign(Close[i+3]-Open[i+3]) == -1)
         p1=smooth_factor;

      double to_be_smoothed= (Buffer_NRSI[i]*1 + Buffer_NRSI[i+1]*p1 +Buffer_NRSI[i+2]*p2)/(1+p1+p2);
      if(to_be_smoothed>Buffer_Hthresh[i+1])
      {
         Buffer_smoothed[i]=to_be_smoothed;
         Buffer_Hthresh[i]=to_be_smoothed;
         Buffer_Lthresh[i]=to_be_smoothed-t_spread;
      }
      else if(to_be_smoothed<Buffer_Lthresh[i+1])
      {
         Buffer_smoothed[i]=to_be_smoothed;
         Buffer_Hthresh[i]=to_be_smoothed+t_spread;
         Buffer_Lthresh[i]=to_be_smoothed;
      }
      else
      {
         Buffer_Hthresh[i]=Buffer_Hthresh[i+1];
         Buffer_Lthresh[i]=Buffer_Lthresh[i+1];
         Buffer_smoothed[i]=Buffer_smoothed[i+1];
      }
   }
   
   return(rates_total);
}
