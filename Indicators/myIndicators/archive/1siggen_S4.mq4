//+------------------------------------------------------------------+
//|                               sig gen for 4-stage plan Evaluation|
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- indicator buffers
double         Buffer_sig[];
double         Buffer_state[];
datetime    _last_open_time;
int limit;
int state=0;
//-----------------macros
#define iMA_fast_len_factor 3
//-----------------inputs
input int iMA_short_len = 20;
input bool use_ADX_confirm = False;
input int ADX_period = 20;
input int ADX_level = 20;
input bool use_RSI_enter = False;
input int RSI_len = 10;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, clrRed);
   SetIndexBuffer(0,Buffer_sig);
   SetIndexLabel(0 ,"favorability signal");   
   
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 1, clrBlueViolet);
   SetIndexBuffer(1,Buffer_state);
   SetIndexLabel(1 ,"state");   
   
   _last_open_time=0;
   limit = 0;
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
//---
   _last_open_time = time[0];
   limit = rates_total - prev_calculated;
//      if(prev_calculated>0)
//         limit++;
   for(int i=limit-1; i >= 0; i--)
   {
      Buffer_sig[i]= sig_digitised(i);
      Buffer_state[i]=state;
    }

//--- return value of prev_calculated for next call
      return(rates_total);
}

double sig_fuzzy(int bar)
{
/*   if(bar > limit-80)
      return 0;
   double imaFast = iMA(Symbol(), Period(), iMA_fast_len, 0, MODE_SMA, PRICE_OPEN, bar);
   double imaSlow = iMA(Symbol(), Period(), iMA_len, 0, MODE_SMA, PRICE_OPEN, bar);

   return 1000*(imaFast-imaSlow);
*/
   return 0;
}

double sig_digitised(int bar)
{  //returns the signal, =1,-1 or 0
   //and update the state
   double imaFast = iMA(Symbol(), Period(), iMA_short_len, 0, MODE_EMA, PRICE_OPEN, bar);
   double imaSlow = iMA(Symbol(), Period(), iMA_short_len * iMA_fast_len_factor, 0, MODE_EMA, PRICE_OPEN, bar);
   double RSI0 = iRSI(Symbol(), Period(), RSI_len,PRICE_CLOSE,bar+1);
   double RSI1 = iRSI(Symbol(), Period(), RSI_len,PRICE_CLOSE,bar+2);

   double ADX = iADX(Symbol(), Period(), ADX_period, PRICE_OPEN, MODE_MAIN, 0);
   double pDI = iADX(Symbol(), Period(), ADX_period, PRICE_OPEN, MODE_PLUSDI, 0);
   double nDI = iADX(Symbol(), Period(), ADX_period, PRICE_OPEN, MODE_MINUSDI, 0);
//   Comment("ADX: ", ADX,"    +: ", pDI,"    -: ", nDI);

   switch(state)
   {
      case 0:  //no trend
         if( (Open[bar]>imaFast) && (imaFast>imaSlow) )
            state = 1;
         else if( (Open[bar]<imaFast) && (imaFast<imaSlow) )
            state = -1;
         break;

      case 1:  //ima in order, wait for confirm
         if( ! ((Open[bar]>imaFast) && (imaFast>imaSlow)) )
            state = 0;  //return t null state
         else
            if(confirm_bull(bar))
               state = 2;
         break;
      case 2:  //confirmed, wait for trade oppurtunity
         if( ! ((Open[bar]>imaFast) && (imaFast>imaSlow)) )
            state = 0;  //return to null state
         else
            if( ! use_RSI_enter)
               state = 3;
            else
               if( (RSI1<70) && (RSI0>RSI1) )
                  state = 3;
         break;
      case 3:  //in trade, wait for trade exit
         if( ! ((Open[bar]>imaSlow) && (imaFast>imaSlow)) )
            state = 0;  //end of trend
         if( use_RSI_enter)
            if( (RSI1>=70) && (RSI0<70) )
               state = 2;  //make profit and return to confirmed state if RSI drop to below 70   
         break;


      case -1:  //ima in order, wait for confirm
         if( ! ((Open[bar]<imaFast) && (imaFast<imaSlow)) )
            state = 0;  //return t null state
         else
            if(confirm_bear(bar))
               state = -2;
         break;
      case -2:  //confirmed, wait for trade oppurtunity
         if( ! ((Open[bar]<imaFast) && (imaFast<imaSlow)) )
            state = 0;  //return t null state
         else
            if( ! use_RSI_enter)
               state = -3;
            else
               if( (RSI1>30) && (RSI0<RSI1) )
                  state = -3;
         break;
      case -3:  //confirmed, wait for trade oppurtunity
         if( ! ((Open[bar]<imaSlow) && (imaFast<imaSlow)) )
            state = 0;  //end of trend
         if( use_RSI_enter)
            if( (RSI1<=30) && (RSI0>30) )
               state = -2; //make profit and return to confirmed state if RSI rises to above 70   
         break;
   }
   if(state>=3)
      return +1;
   else if(state<=-3)
      return -1;
   else
      return 0;

                                                         
}//+------------------------------------------------------------------+
bool confirm_bull(int bar)
{
   if( ! use_ADX_confirm)
      return true;
   double ADX = iADX(Symbol(), Period(), ADX_period, PRICE_OPEN, MODE_MAIN, bar);
   double pDI = iADX(Symbol(), Period(), ADX_period, PRICE_OPEN, MODE_PLUSDI, bar);
   double nDI = iADX(Symbol(), Period(), ADX_period, PRICE_OPEN, MODE_MINUSDI, bar);

   if( (pDI>nDI) && (ADX>ADX_level) )
      return true;
   else
      return false;
}
bool confirm_bear(int bar)
{
   if( ! use_ADX_confirm)
      return true;
   double ADX = iADX(Symbol(), Period(), ADX_period, PRICE_OPEN, MODE_MAIN, bar);
   double pDI = iADX(Symbol(), Period(), ADX_period, PRICE_OPEN, MODE_PLUSDI, bar);
   double nDI = iADX(Symbol(), Period(), ADX_period, PRICE_OPEN, MODE_MINUSDI, bar);

   if( (pDI<nDI) && (ADX>ADX_level) )
      return true;
   else
      return false;
}