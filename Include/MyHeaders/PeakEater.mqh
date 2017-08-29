//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
class PeakEater
{
   bool looking_for_A;
 public:
   PeakEater();
  
};
PeakEater::PeakEater():looking_for_A(false)
{
}
bool PeakEater::take_sample(double _rsi)