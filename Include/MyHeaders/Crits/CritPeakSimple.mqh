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
   double V0, V1, V2, A0, A1, A2;
   int accept_thresh;
   bool twin_peaks;
 public:
   PeakSimple(int _thresh, int _base_weight, bool _twin_peaks);
   virtual double get_advice(bool _for_buy);	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   virtual void take_input(double _V0,double _V1, double _V2,double _A0 ,double _A1,double _A2);
};
PeakSimple::PeakSimple(int _thresh, int _base_weight, bool _twin_peaks):CriteriaBase(_base_weight),accept_thresh(_thresh), twin_peaks(_twin_peaks)
{
}
void PeakSimple::take_input(double _V0,double _V1, double _V2,double _A0 ,double _A1,double _A2)
{
   V0=_V0; V1=_V1; V2=_V2; A0=_A0; A1=_A1; A2=_A2;
}
double PeakSimple::get_advice(bool _for_buy)
{	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
	int desirability = 0;
   if(_for_buy)
   {
   	if(A0>=70 || (twin_peaks && (A1>=70)))
   		desirability +=1;
   	if(V0>15)
   		desirability +=1;
   	if(A0-V0>accept_thresh)
   		desirability +=1;
   }
   if(!_for_buy)
   {
   	if(V0<=30 || (twin_peaks && (V1<=30)))
   		desirability +=1;
   	if(A0<85)
   		desirability +=1;
   	if(A0-V0>accept_thresh)
   		desirability +=1;
   }
   if(desirability>=3)
      return 1;
   else
      return 0;
}
