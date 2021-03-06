//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

#include <MyHeaders\Crits\CriteriaBase.mqh>

//+------------------------------------------------------------------+
class PeakDigester : public CriteriaBase
{
 public:
   PeakDigester(int _base_weight);
   virtual double get_advice(bool _for_buy);	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
//   virtual void take_input(PeakEaterResult _event, double _peak, double _rsi);
//   virtual void take_input(double _SAR);
};
PeakDigester::PeakDigester(int _base_weight):CriteriaBase(_base_weight)
{
}
double PeakDigester::get_advice(bool _for_buy)
{	//0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
}
void PeakDigester::take_input()
{
}
