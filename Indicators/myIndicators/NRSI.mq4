//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_level1 0
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_maximum 100
#property indicator_minimum -100

//--- indicator buffers
double         Buffer_NRSI[];
//-----------------inputs
input int NRSI_len=10;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(0,Buffer_NRSI);
   SetIndexLabel(0 ,"NRSI");   
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
      limit-=NRSI_len+1;  // to avoid the array out of range problem when counted_bars==0
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
         diff = Open[i+j]-Open[i+j+1];
         if(diff>0)
            pos_bars += diff*(NRSI_len-j);
         else
            neg_bars -= diff*(NRSI_len-j);
      }
      Buffer_NRSI[i] = 100 * (pos_bars-neg_bars) / (pos_bars+neg_bars);
   }
   
   return(rates_total);
}
