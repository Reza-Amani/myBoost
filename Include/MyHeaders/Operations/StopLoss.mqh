//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
class StopLoss
{
   double step,maximum;
 public:
   StopLoss(double _step,double _maximum);
   double get_sl(bool _for_buy, double _price);
   
};
StopLoss::StopLoss(double _step,double _maximum):step(_step),maximum(_maximum)
{
}
double StopLoss::get_sl(bool _for_buy, double _price)
{
   double SAR = iSAR(NULL,0, step, maximum, 0);
   if(_for_buy)
      return (SAR<_price)? SAR : 3*_price-2*SAR;
   else
      return (SAR>_price)? SAR : 3*_price-2*SAR;
}
