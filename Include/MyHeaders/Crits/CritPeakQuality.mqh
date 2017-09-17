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
class PeakQuality : public CriteriaBase
{
 private:
   double last_VA, V0, V1, V2, A0, A1, A2;
 public:
   PeakQuality(int _base_weight);
   virtual double get_advice(bool _for_buy);	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   virtual void take_input(double _last_VA, double _V0,double _V1, double _V2,double _A0 ,double _A1,double _A2);
};
PeakQuality::PeakQuality(int _base_weight):CriteriaBase(_base_weight)
{
}
void PeakQuality::take_input(double _last_VA, double _V0,double _V1, double _V2,double _A0 ,double _A1,double _A2)
{
   last_VA=_last_VA; V0=_V0; V1=_V1; V2=_V2; A0=_A0; A1=_A1; A2=_A2;
}
double PeakQuality::get_advice(bool _for_buy)
{	//0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   int desirability=0;
   if(_for_buy)
   {
      if(last_VA>60 || last_VA==1)
         desirability -= 5;
      if(V0==1)
         desirability -= 2;
      if(A0<70)
         desirability -= 3;
      if(A1<70)
         desirability -= 1;
      if(A0==99)
         desirability += 3
      else if(A0>90)
         desirability += 2;
      else if(A0>80)
         desirability += 1;
         
      if(A1<=A0 && A1>70)
         desirability += 2;
         
      if(last_VA>V0-5 && last_VA<V0+25)
         desirability += 2;
   }
   else
   {  //for sell
      if(last_VA<40 || last_VA==99)
         desirability -= 5;
      if(A0==99)
         desirability -= 2;
      if(V0>30)
         desirability -= 3;
      if(V1>30)
         desirability -= 1;
      if(V0==1)
         desirability += 3
      else if(V0<10)
         desirability += 2;
      else if(V0<20)
         desirability += 1;
         
      if(V1>=V0 && V1<30)
         desirability += 2;
         
      if(last_VA<A0+5 && last_VA>A0-25)
         desirability += 2;
   }
}
