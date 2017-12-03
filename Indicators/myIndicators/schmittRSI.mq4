//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_maximum 100
#property indicator_minimum 0
#property indicator_level1  30
#property indicator_level2  70
//--- indicator buffers
double         Buffer_schmittRSI[];
//-----------------macros
//-----------------inputs
input int RSI_len=14;
input int schmitt_threshold=5;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrYellowGreen);
   SetIndexBuffer(0,Buffer_schmittRSI);
   SetIndexLabel(0 ,"schmittRSI");   
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
   if(Bars<RSI_len+1) return(-1); //not enough bars
   //--- position of the bar from which calculation in the loop starts
   int limit;

   //--- if counted_bars=0, reduce the starting position in the loop by 1,   
   if(counted_bars==0) 
   {  //first run on the chart
      double initial_value = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,Bars-1-RSI_len);
      initial_value = round(initial_value/schmitt_threshold)*schmitt_threshold;
      for(int i=Bars-1;i>Bars-1-RSI_len;i--)
         Buffer_schmittRSI[i] = initial_value; 
      limit=Bars-1-RSI_len;
   }
   else //--- the indicator has been already calculated, counted_bars>0
      limit=Bars-counted_bars-1;
   
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double rsi0 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,i+0); 
      double scale = 1+0.03*(RSI_len-14);
      double scaledRSI = 50+ scale*(rsi0-50);
      if(scaledRSI >= Buffer_schmittRSI[i+1]+schmitt_threshold)
         Buffer_schmittRSI[i] = round(scaledRSI/schmitt_threshold)*schmitt_threshold;
      else if(scaledRSI <= Buffer_schmittRSI[i+1]-schmitt_threshold)
         Buffer_schmittRSI[i] = round(scaledRSI/schmitt_threshold)*schmitt_threshold;
      else
         Buffer_schmittRSI[i] = Buffer_schmittRSI[i+1];
         
      if(Buffer_schmittRSI[i]>85)
         Buffer_schmittRSI[i]=85;
      if(Buffer_schmittRSI[i]<15)
         Buffer_schmittRSI[i]=15;
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
