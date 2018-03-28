//+------------------------------------------------------------------+
//|                                             PredMACD.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
class PredMACD
{
   double DefaultFastEMA,DefaultSignalSMA;
   double CalcPred(int _FastEMA, int _SignalSMA, int _SlowEMA, bool _past_bar);
 public:
   double GetPred();
   double GetTrialPred(int _FastEMA, int _SignalSMA);
   double GetPastPred();
   double GetPastTrialPred(int _FastEMA, int _SignalSMA);
   int FastEMA,SignalSMA;
   PredMACD(int _FastEMA, int _SignalSMA);
   void UpdatePars(int _FastEMA, int _SignalSMA);
  
};

PredMACD::PredMACD(int _FastEMA, int _SignalSMA):DefaultFastEMA(_FastEMA),DefaultSignalSMA(_SignalSMA)
{
   UpdatePars(_FastEMA,_SignalSMA);
}
void PredMACD::UpdatePars(int _FastEMA,int _SignalSMA)
{
   FastEMA = _FastEMA;
   SignalSMA = _SignalSMA;
}

double PredMACD::GetPred(void)
{
   return CalcPred(FastEMA, SignalSMA, 2*FastEMA, false);
}
double PredMACD::GetTrialPred(int _FastEMA,int _SignalSMA)
{
   return CalcPred(_FastEMA, _SignalSMA, 2*_FastEMA, false);
}
double PredMACD::GetPastPred(void)
{
   return CalcPred(FastEMA, SignalSMA, 2*FastEMA, true);
}
double PredMACD::GetPastTrialPred(int _FastEMA,int _SignalSMA)
{
   return CalcPred(_FastEMA, _SignalSMA, 2*_FastEMA, true);
}
double PredMACD::CalcPred(int _FastEMA,int _SignalSMA,int _SlowEMA, bool _past_bar)
{
   int delay = (_past_bar)?2:1;
   double   macd_macd = iCustom(Symbol(), Period(),"myIndicators/myMACD", FastEMA, SignalSMA, 0,delay); 
   double   macd_sig_ma = iCustom(Symbol(), Period(),"myIndicators/myMACD", FastEMA, SignalSMA, 1,delay); 
   double   macd_force = iCustom(Symbol(), Period(),"myIndicators/myMACD", FastEMA, SignalSMA, 2,delay); 
   double   macd_dforce = iCustom(Symbol(), Period(),"myIndicators/myMACD", FastEMA, SignalSMA, 3,delay); 
   return 7;//macd_macd;
}

/*double StopLoss::get_sl(bool _for_buy, double _price, double _last_lowhigh)
{
   double SAR = iSAR(NULL,0, step, maximum, 0);
   if(_for_buy)
   {
      if(SAR>=_price)
         SAR = iSAR(NULL,0, step*2, maximum, 0);
      if(SAR>=_price)
         SAR = iSAR(NULL,0, step*4, maximum, 0);
      if(SAR>=_price)
         SAR = 3*_last_lowhigh-2*iSAR(NULL,0, step, maximum, 0);
      if(SAR>=_price)
         SAR = 0;
   }
 */