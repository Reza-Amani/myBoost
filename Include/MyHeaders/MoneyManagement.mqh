//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict
//+------------------------------------------------------------------+
class MoneyManagement
{
   double base_lots;
 public:
   MoneyManagement(double _base_lots);
   double get_lots(double _trust);
   
};
MoneyManagement::MoneyManagement(double _base_lots):base_lots(_base_lots)
{
   
}
double MoneyManagement::get_lots(double _trust)
{
   return base_lots*_trust;
}
