//+------------------------------------------------------------------+
//|                                             money_management.mqh |
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
   double CalcPred(int _FastEMA, int _SignalSMA, int _SlowEMA);
 public:
   double GetPred();
   double GetTrialPred(int _FastEMA, int _SignalSMA);
   double FastEMA,SignalSMA;
   PredMACD(int _FastEMA, int _SignalSMA);
   UpdatePars(int _FastEMA, int _SignalSMA);
  
};

PredMACD::PredMACD(int _FastEMA, int _SignalSMA):DefaultFastEMA(_FastEMA),DefaultSignalSMA(_SignalSMA)
{
   UpdatePars(_FastEMA,_SignalSMA);
}
void PredMACD::UpdatePars(int _FastEMA,int _SignalSMA)
{
   FastEMA = _FastEMA;
   SignalSMA = _SignalSMA
}

PredMACD::GetPred(void)
{
   return CalcPred(FastEMA, SignalEMA, 2*FastEMA);
}
PredMACD::GetTrialPred(int _FastEMA,int _SignalSMA)
{
   return CalcPred(_FastEMA, _SignalEMA, 2*_FastEMA);
}
PredMACD::CalcPred(int _FastEMA,int _SignalSMA,int _SlowEMA)
{
   double   macd_macd = iCustom(Symbol(), Period(),"myIndicators/myMACD", MACD_len, MACD_ma, 0,1); 
   double   macd_sig_ma = iCustom(Symbol(), Period(),"myIndicators/myMACD", MACD_len, MACD_ma, 1,1); 
   double   macd_force = iCustom(Symbol(), Period(),"myIndicators/myMACD", MACD_len, MACD_ma, 2,1); 
   double   macd_dforce = iCustom(Symbol(), Period(),"myIndicators/myMACD", MACD_len, MACD_ma, 3,1); 
   return macd_macd;
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