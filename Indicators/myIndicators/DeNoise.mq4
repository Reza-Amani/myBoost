//+------------------------------------------------------------------+
//|                                       Denoise.mq4 |
//|                   Copyright 2005-2015, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property description "Denoise"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow
//--- indicator parameters
input int            DenoiseSize=3;        
//--- indicator buffer
double Buffer_Denoise[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorShortName("Denoise("+string(DenoiseSize)+")");
   IndicatorDigits(Digits);
//--- check for input
   if(DenoiseSize<1)
      return(INIT_FAILED);
//--- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,0);
   SetIndexDrawBegin(0,DenoiseSize);
//--- indicator buffers mapping
   SetIndexBuffer(0,Buffer_Denoise);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|  Moving Average                                                  |
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
//--- check for bars count
   if(rates_total<DenoiseSize || DenoiseSize<1)
      return(0);
   //--- position of the bar from which calculation in the loop starts
   int counted_bars=IndicatorCounted();
   int limit=Bars-counted_bars-1;

   //--- if counted_bars=0, reduce the starting position in the loop by 1,   
   if(counted_bars==0) 
      limit-=DenoiseSize;  // to avoid the array out of range problem when counted_bars==0; limit-- if [i+1] is not needed
//   else //--- the indicator has been already calculated, counted_bars>0
//      limit++;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
   
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double result=0;
      for (int j=0; j<DenoiseSize; j++)
         result += open[i+j];//Close[i+j+1]; //open[i+j]
      Buffer_Denoise[i] = result/DenoiseSize;
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
