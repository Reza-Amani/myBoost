#property strict

#include <MovingAverages.mqh>

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Silver
#property  indicator_color2  Blue
#property  indicator_color3  Yellow
#property  indicator_color4  Red
#property  indicator_width1  2
//--- indicator parameters
input int InpFastEMA=12;   // Fast EMA Period
input int InpSignalSMA=9;  // Signal SMA Period
int InpSlowEMA=2*InpFastEMA;   // Slow EMA Period
//--- indicator buffers
double    ExtMacdBuffer[];
double    ExtSignalBuffer[];
double    forceBuffer[];
double    dforceBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;
double    NormalBarSize=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexDrawBegin(1,InpSignalSMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer);
   SetIndexBuffer(1,ExtSignalBuffer);
   SetIndexBuffer(2,forceBuffer);
   SetIndexBuffer(3,dforceBuffer);
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"force");
   SetIndexLabel(3,"dforce");
//--- check for input parameters
   if(InpFastEMA<=1 || InpSlowEMA<=1 || InpSignalSMA<=1 || InpFastEMA>=InpSlowEMA)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
  {
   int i,limit;
//---
   if(rates_total<=InpSignalSMA || !ExtParameters)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
   else
   {
      for(i=0; i<limit; i++)
         NormalBarSize+=High[i]-Low[i];
      NormalBarSize=NormalBarSize/limit;
   }
//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++)
      ExtMacdBuffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                    iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//--- signal line counted in the 2-nd buffer
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
   for(i=limit-1; i>=0; i--)
   {
      forceBuffer[i]=ExtMacdBuffer[i]-ExtSignalBuffer[i];
      if(i!=limit-1)
         dforceBuffer[i]=forceBuffer[i]-forceBuffer[i+1];
      else
         dforceBuffer[i]=0;
/*      if(ExtMacdBuffer[i]>0 && ExtMacdBuffer[i]>ExtSignalBuffer[i])
         moodBuffer[i]=NormalBarSize*1;
      else if(ExtMacdBuffer[i]>0 && ExtMacdBuffer[i]<=ExtSignalBuffer[i])
         moodBuffer[i]=NormalBarSize*0.5;
      else if(ExtMacdBuffer[i]<0 && ExtMacdBuffer[i]<ExtSignalBuffer[i])
         moodBuffer[i]=NormalBarSize*(-1);
      else if(ExtMacdBuffer[i]<0 && ExtMacdBuffer[i]>=ExtSignalBuffer[i])
         moodBuffer[i]=NormalBarSize*(-0.5);
*/
   }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+