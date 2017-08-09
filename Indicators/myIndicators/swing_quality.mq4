//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_maximum 100
#property indicator_minimum 0
//--- indicator buffers
double         Buffer_buy_quality[];
double         Buffer_sell_quality[];
double         Buffer_both_quality[];
double         Buffer_total_smoothed_quality[];
double         Buffer_peak_turn[];
//-----------------macros
//-----------------inputs
input int RSI_len=14;
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
   SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 1, clrWhiteSmoke);
   SetIndexBuffer(2,Buffer_both_quality);
   SetIndexLabel(2 ,"both");   
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, clrGold);
   SetIndexBuffer(3,Buffer_total_smoothed_quality);
   SetIndexLabel(3 ,"total");   
   SetIndexStyle(4, DRAW_NONE, STYLE_SOLID, 1, clrGold);
   SetIndexBuffer(4,Buffer_peak_turn);
   SetIndexLabel(4 ,"turn");   
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
      Buffer_buy_quality[Bars-1]=0;
      Buffer_sell_quality[Bars-1]=0;
      Buffer_both_quality[Bars-1]=0;
      Buffer_total_smoothed_quality[Bars-1]=0;
      Buffer_peak_turn[0]=false;
      limit--; //reset the first value and start from the second one
   }
//   else //--- the indicator has been already calculated, counted_bars>0
//      limit++;//--- for repeated calls increase limit by 1 to update the indicator values for the last bar
   
   //--- the main calculation loop
   for (int i=limit; i>=0; i--)
   {
      double rsi0 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,i+0); 
      double rsi1 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,i+1);
      double rsi2 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,i+2);
      double rsi3 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,i+3);
      double rsi4 = iCustom(Symbol(), Period(),"Market/Fast and smooth RSI", RSI_len, MODE_SMMA, PRICE_MEDIAN ,0,i+4);
      
      Buffer_buy_quality[i]=Buffer_buy_quality[i+1];
      //Buy quality calculation
      if(rsi0>=70 && rsi1<=70 && Buffer_peak_turn[i+1])
      {
         Buffer_peak_turn[i]=false;
         Buffer_buy_quality[i] += +6;
      }
      if(rsi0<=40 && rsi1>=40 && !Buffer_peak_turn[i+1])
      {  
         Buffer_peak_turn[i] = true;
         Buffer_buy_quality[i] += +4;
      }
      if(rsi0<=20)
         Buffer_buy_quality[i] += -1.5;
      if(rsi0>=rsi1 && rsi1>=rsi2 && rsi2<=rsi3 && rsi3<=rsi4 && rsi2<70 && rsi2>40)
         Buffer_buy_quality[i] += -3;
      if(rsi0<=rsi1 && rsi1<=rsi2 && rsi2>=rsi3 && rsi3>=rsi4 && rsi2<70 && rsi2>40)
         Buffer_buy_quality[i] += -5;
      
      if(rsi0>rsi1 && rsi1>rsi2 && rsi2>rsi3 && rsi3>rsi4)
         Buffer_buy_quality[i] += +0.5;

      if(Buffer_buy_quality[i]<0)
         Buffer_buy_quality[i]=0;
      if(Buffer_buy_quality[i]>=70)
         Buffer_buy_quality[i]=70;
         
         
         
         
         
//      Buffer_buy_quality[i]=(i%100>=50)?5:-5;
      Buffer_sell_quality[i]=rsi0;
//      Buffer_total_smoothed_quality[i]=iMAOnArray(Buffer_buy_quality,0,4,0,MODE_SMA,i);
      Buffer_total_smoothed_quality[i]=Buffer_total_smoothed_quality[i+1]+Buffer_buy_quality[i];
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
