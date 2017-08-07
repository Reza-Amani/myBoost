//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_maximum 100
#property indicator_minimum 0
//--- indicator buffers
double         Buffer_buy_quality[];
double         Buffer_sell_quality[];
double         Buffer_total_smoothed_quality[];
//-----------------macros
//-----------------inputs
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 1, clrGreen);
   SetIndexBuffer(0,Buffer_buy_quality);
   SetIndexLabel(0 ,"buy");   
   SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 1, clrPaleVioletRed);
   SetIndexBuffer(1,Buffer_sell_quality);
   SetIndexLabel(1 ,"sell");   
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, clrGold);
   SetIndexBuffer(2,Buffer_total_smoothed_quality);
   SetIndexLabel(2 ,"total");   
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
      limit--;  // to avoid the array out of range problem when counted_bars==0
   else //--- the indicator has been already calculated, counted_bars>0
      limit++;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
      
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double rsi1 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", 14, MODE_SMMA, PRICE_MEDIAN ,0,i+1); 
      double rsi2 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", 14, MODE_SMMA, PRICE_MEDIAN ,0,i+2);
      Buffer_buy_quality[i]=(i%100>50)?50:0;
      Buffer_sell_quality[i]=rsi2;
      Buffer_total_smoothed_quality[i]=iMAOnArray(Buffer_buy_quality,0,4,0,MODE_SMA,i);
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
