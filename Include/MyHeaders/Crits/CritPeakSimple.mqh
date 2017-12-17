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
   int ave_len;
	MyMath math;
 public:
   PeakSimple(int _thresh, int _base_weight, bool _twin_peaks, int _ave_len);
   virtual double get_advice(double _rsi1, double _rsi2, double _rsi3);
   virtual void take_input(double _V0,double _V1, double _V2,double _A0 ,double _A1,double _A2);
   double get_mood(double _current_RSI, bool _rising);
};
PeakSimple::PeakSimple(int _thresh, int _base_weight, bool _twin_peaks, int _ave_len):CriteriaBase(_base_weight),accept_thresh(_thresh), twin_peaks(_twin_peaks), ave_len(_ave_len)
{
}
double PeakSimple::get_mood(double _current_RSI, bool _rising)
{
   switch(ave_len)
   {
      case 2:
         return _rising ? (math.max(_current_RSI-V0,A0-V0) + A0-V0)/2 : (math.max(A0-_current_RSI,A0-V0) + A0-V0)/2;
      case 3:
         return _rising ? (math.max(_current_RSI-V0,A0-V0) + A0-V0 + A0-V1)/3 : (math.max(A0-_current_RSI,A0-V0) + A0-V0 + A1-V0)/3;
   }
   return 0;
}
void PeakSimple::take_input(double _V0,double _V1, double _V2,double _A0 ,double _A1,double _A2)
{
   V0=_V0; V1=_V1; V2=_V2; A0=_A0; A1=_A1; A2=_A2;
}
double PeakSimple::get_advice(double _rsi1, double _rsi2, double _rsi3)
{	//0 none, 1 buy, -1 sell
	int desirability = 0;
   int dir=0;
   if(_rsi2==V0 && _rsi1>V0)
      dir=1;
   else if(_rsi2==A0 && _rsi1<A0)
      dir=-1;   
   else if(_rsi3==V0 && _rsi1>V0)
      dir=1;
   else if(_rsi3==A0 && _rsi1<A0)
      dir=-1;   
      
   if(dir==0)
      return 0;
      
   if(dir==1)
   {
   	if(A0>=70 || (twin_peaks && (A1>=70)))
      	if(V0>15)
         	if(A0-_rsi1>accept_thresh)
               return 1;
   }
   if(dir==-1)
   {
   	if(V0<=30 || (twin_peaks && (V1<=30)))
      	if(A0<85)
         	if(_rsi1-V0>accept_thresh)
               return -1;
   }
   return 0;
}
