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
class PeakSimple : public CriteriaBase
{
 private:
   double last_VA, V0, V1, V2, A0, A1, A2;
 public:
   PeakSimple(int _base_weight);
   virtual double get_advice(bool _for_buy);	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   virtual void take_input(double _last_VA, double _V0,double _V1, double _V2,double _A0 ,double _A1,double _A2);
};
PeakSimple::PeakSimple(int _base_weight):CriteriaBase(_base_weight)
{
}
void PeakSimple::take_input(double _last_VA, double _V0,double _V1, double _V2,double _A0 ,double _A1,double _A2)
{
   last_VA=_last_VA; V0=_V0; V1=_V1; V2=_V2; A0=_A0; A1=_A1; A2=_A2;
}
double PeakSimple::get_advice(bool _for_buy)
{	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
	int desirability = 0;
   if(_for_buy)
   {
   	if(last_VA>=V0)
   		desirability ++;
   	if(last_VA<50)
   		desirability ++;
   	if(A0>=80)
   		desirability ++;
   }
   if(!_for_buy)
   {
   	if(last_VA<=A0)
   		desirability ++;
   	if(last_VA>50)
   		desirability ++;
   	if(V0<=20)
   		desirability ++;
   }
   
   switch(desirability)
   {
      default:
      case 0:
      case 1:
      case 2:
         return 0;
         break;
      case 3:
         return 1;
         break;
   }
}