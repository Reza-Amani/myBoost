#property strict

#include <MovingAverages.mqh>
#include <MyHeaders\PredMACD.mqh>

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 5
#property  indicator_color1  Silver
#property  indicator_color2  Blue
#property  indicator_color3  Yellow
#property  indicator_color4  Red
#property  indicator_color5  White
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
double    predBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;
double    NormalBarSize=0;

PredMACD* pred;
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
   SetIndexStyle(4,DRAW_LINE);
   SetIndexDrawBegin(1,InpSignalSMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer);
   SetIndexBuffer(1,ExtSignalBuffer);
   SetIndexBuffer(2,forceBuffer);
   SetIndexBuffer(3,dforceBuffer);
   SetIndexBuffer(4,predBuffer);
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"force");
   SetIndexLabel(3,"dforce");
   SetIndexLabel(4,"pred");
//--- check for input parameters
   if(InpFastEMA<=1 || InpSlowEMA<=1 || InpSignalSMA<=1 || InpFastEMA>=InpSlowEMA)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
      
   pred = new PredMACD(InpFastEMA,InpSignalSMA);
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
      ExtMacdBuffer[i]=(iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                    iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i))/iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i)*100;
//--- signal line counted in the 2-nd buffer
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
   for(i=limit-1; i>=0; i--)
   {
      forceBuffer[i]=ExtMacdBuffer[i]-ExtSignalBuffer[i];
      if(prev_calculated>0 || i!=limit-1)
      {
         dforceBuffer[i]=forceBuffer[i]-forceBuffer[i+1];
         predBuffer[i]=pred.GetPred();//Pred(InpFastEMA,InpSignalSMA,InpSlowEMA,false);
      }
      else
      {
         dforceBuffer[i]=0;
         predBuffer[i]=0;
      }
   }
   return(rates_total);
}
//+------------------------------------------------------------------+