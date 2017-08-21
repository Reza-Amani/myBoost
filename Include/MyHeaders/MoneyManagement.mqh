//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

#include <MyHeaders\MyMath.mqh>
//+------------------------------------------------------------------+
class MoneyManagement
{
   double max_risk;
   double base_lots;
   MyMath math;
 public:
   MoneyManagement(double _base_lots);
   double get_lots(double _trust, double _open, double _sl, double _equity);
   
};
MoneyManagement::MoneyManagement(double _base_lots):base_lots(_base_lots)
{
   max_risk=0.1;
}
double MoneyManagement::get_lots(double _trust, double _open, double _sl, double _equity)
{
   double requested_lot = base_lots*_trust;
   if(_open==_sl)
      return 0;   //invalid inputs
   if(requested_lot * 100000 * (math.abs(_open-_sl))< max_risk*_equity)
      return requested_lot;   //a reasonable size trade requested
   else
      return max_risk*_equity / (100000*(math.abs(_open-_sl)));
}
