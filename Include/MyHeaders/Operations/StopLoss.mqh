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
   double get_sl_SAR(bool _for_buy, double _price, double _last_lowhigh);
   double get_sl_barsize(bool _for_buy, double _price, double _ave_barsize, double _sl_factor);
   
};
StopLoss::StopLoss(double _step,double _maximum):step(_step),maximum(_maximum)
{
}
double StopLoss::get_sl_barsize(bool _for_buy, double _price, double _ave_barsize, double _sl_factor)
{
   if(_for_buy)
      return _price-_ave_barsize*_sl_factor;
   else
      return _price+_ave_barsize*_sl_factor;
}
double StopLoss::get_sl_SAR(bool _for_buy, double _price, double _last_lowhigh)
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
   else
   {
      if(SAR<=_price)
         SAR = iSAR(NULL,0, step*2, maximum, 0);
      if(SAR<=_price)
         SAR = iSAR(NULL,0, step*4, maximum, 0);
      if(SAR<=_price)
         SAR = 3*_last_lowhigh-2*iSAR(NULL,0, step, maximum, 0);
      if(SAR<=_price)
         SAR = 0;
   }
      
   return SAR;
}
