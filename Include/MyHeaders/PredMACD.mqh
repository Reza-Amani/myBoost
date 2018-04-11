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
   double CalcPred(int _FastEMA, int _SignalSMA, int _SlowEMA, int shift);
 public:
   double GetPred();
   double GetTrialPred(int _FastEMA, int _SignalSMA, int shift);
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
   return CalcPred(FastEMA, SignalSMA, 2*FastEMA, 1);
}
double PredMACD::GetTrialPred(int _FastEMA,int _SignalSMA, int shift)
{
   return CalcPred(_FastEMA, _SignalSMA, 2*_FastEMA, shift);
}
double PredMACD::GetPastPred(void)
{
   return CalcPred(FastEMA, SignalSMA, 2*FastEMA, 2);
}
double PredMACD::GetPastTrialPred(int _FastEMA,int _SignalSMA)
{
   return CalcPred(_FastEMA, _SignalSMA, 2*_FastEMA, 2);
}
double PredMACD::CalcPred(int _FastEMA,int _SignalSMA,int _SlowEMA, int shift)
{
   double   macd_macd = iCustom(Symbol(), Period(),"myIndicators/myMACD", FastEMA, SignalSMA, 0,shift); 
   double   macd_sig_ma = iCustom(Symbol(), Period(),"myIndicators/myMACD", FastEMA, SignalSMA, 1,shift); 
   double   macd_force = iCustom(Symbol(), Period(),"myIndicators/myMACD", FastEMA, SignalSMA, 2,shift); 
   double   macd_dforce = iCustom(Symbol(), Period(),"myIndicators/myMACD", FastEMA, SignalSMA, 3,shift); 
   return macd_macd;
}

