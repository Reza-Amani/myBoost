//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

#include <MyHeaders\CriteriaBase.mqh>

//+------------------------------------------------------------------+
class ParabolicLover : public CriteriaBase
{
 public:
   ParabolicLover(int _base_weight);
   virtual double get_advice(bool _for_buy);	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   virtual void take_input(double _SAR);
   
//   void take_event(PeakEaterResult _event, double _recent_peak, double _rsi);
};
ParabolicLover::ParabolicLover(int _base_weight):CriteriaBase(_base_weight)
{
}
double ParabolicLover::get_advice(bool _for_buy)
{	//0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   return 0;
}
void ParabolicLover::take_input(double _SAR)
{
}
