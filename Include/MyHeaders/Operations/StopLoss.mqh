//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

enum SL_TYPE
{
   SL_NONE,
   SL_BARSIZE,
   SL_SAR
};
//+------------------------------------------------------------------+
class StopLoss
{
   double step,maximum;
   double sl_factor;
   SL_TYPE algo;
 public:
   StopLoss(SL_TYPE _algo, double _slfactor_or_step,double _maximum);
   double get_sl(bool _for_buy, double _price, double _ave_barsize, double _last_lowhigh);
};
StopLoss::StopLoss(SL_TYPE _algo, double _slfactor_or_step,double _maximum):algo(_algo),sl_factor(_slfactor_or_step),step(_slfactor_or_step),maximum(_maximum)
{
}
double StopLoss::get_sl(bool _for_buy, double _price, double _ave_barsize, double _last_lowhigh)
{
   double SAR;
   switch(algo)
   {
      case SL_BARSIZE:
         if(_for_buy)
            return _price-_ave_barsize*sl_factor;
         else
            return _price+_ave_barsize*sl_factor;
      case SL_SAR: 
         SAR = iSAR(NULL,0, step, maximum, 0);
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
      case SL_NONE:
      default:
         return 0;
   }
}
