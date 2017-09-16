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
class ParabolicLover : public CriteriaBase
{
 private:
   double step,max;
   int bars_from_last_flip;
   double last_SAR;
 public:
   ParabolicLover(int _base_weight,double _step, double _max);
   virtual double get_advice(bool _for_buy);	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   virtual void take_input();
   
//   void take_event(PeakEaterResult _event, double _recent_peak, double _rsi);
};
ParabolicLover::ParabolicLover(int _base_weight,double _step, double _max):CriteriaBase(_base_weight),step(_step),max(_max)
{
   bars_from_last_flip=0;
   last_SAR = iSAR(NULL,0, step, max, 0);
}
double ParabolicLover::get_advice(bool _for_buy)
{	//0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   double SAR = iSAR(NULL,0, step, max, 0);
   if(_for_buy)
      if(SAR>Open[0])
         return 0.1;    //Veto?
   if(!_for_buy)
      if(SAR<Open[0])
         return 0.1;    //Veto?
   if(bars_from_last_flip>20)
      return 0.2;
   else if(bars_from_last_flip>10)        
      return 0.4;
   else if(bars_from_last_flip>6)        
      return 1;
   else if(bars_from_last_flip>3)        
      return 2;
   else
      return 4;
}
void ParabolicLover::take_input()
{
   double SAR = iSAR(NULL,0, step, max, 0);
   if((SAR>Open[0] && last_SAR>Open[1]) || (SAR<Open[0] && last_SAR<Open[1])) //no change
      bars_from_last_flip++;
   else
      bars_from_last_flip=0;
   
   last_SAR = SAR;
   
}
