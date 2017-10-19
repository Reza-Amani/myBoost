//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
class TakeProfit
{
   double factor;
 public:
   TakeProfit(double _factor);
   double get_tp(bool _for_buy, double _sl, double _price);
   
};
TakeProfit::TakeProfit(double _factor):factor(_factor)
{
}
double TakeProfit::get_tp(bool _for_buy, double _sl, double _price)
{
   if(_for_buy)
      return (_sl<_price)? _price + factor*(_price-_sl) : 0;
   else
      return (_sl>_price)? _price + factor*(_price-_sl) : 0;
}
