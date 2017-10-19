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
   void take_new_bite_buy(double _new_bite);
   void take_new_bite_sell(double _new_bite);
   void decay_dishes();
 public:
   double buy_dish,sell_dish;
   virtual double get_advice(bool _for_buy);
   PeakDigester(int _base_weight);
   virtual void take_input(PeakEaterResult _event, double _peak, double _rsi);
};
PeakDigester::PeakDigester(int _base_weight):CriteriaBase(_base_weight)
{
   buy_dish=0; sell_dish=0;
}
double PeakDigester::get_advice(bool _for_buy)
{	//0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   if(_for_buy)
   {	//range of -2 .. +4
      if(buy_dish>=45)
         return 4;
      if(buy_dish>=35)
         return 2;
      if(buy_dish>=25)
         return 1;
      if(buy_dish>=15)
         return 0.4;
      if(buy_dish>=10)
         return 0.2;
      if(buy_dish>=5)
         return 0.1;
      return 0;
   }
   else
   {	//range of -2 .. +4
      if(sell_dish>=45)
         return 4;
      if(sell_dish>=35)
         return 2;
      if(sell_dish>=25)
         return 1;
      if(sell_dish>=15)
         return 0.4;
      if(sell_dish>=10)
         return 0.2;
      if(sell_dish>=5)
         return 0.1;
      return 0;
   }
}
void PeakDigester::take_input(PeakEaterResult _event, double _peak, double _rsi)
{
	switch(_event)
	{
	   case RESULT_CONTINUE:
	      if(_rsi>40 && _rsi<60)
   		   decay_dishes();
			break;
		case RESULT_CONFIRM_A:
		   if(_peak>60)
		   take_new_bite_buy(2*(_peak-60));
		   if(_peak==99)
		      take_new_bite_sell(0);
			break;
		case RESULT_CONFIRM_V:
		   if(_peak<40)
		      take_new_bite_sell(2*(40-_peak));
		   if(_peak==1)
		      take_new_bite_buy(0);
			break;
	}
}
void PeakDigester::take_new_bite_buy(double _new_bite)
{
   buy_dish = (buy_dish*2 + _new_bite)/(2+1);
}
void PeakDigester::take_new_bite_sell(double _new_bite)
{
   sell_dish = (sell_dish*2 + _new_bite)/(2+1);
}
void PeakDigester::decay_dishes(void)
{
   sell_dish -= 0.5;
   buy_dish -= 0.5;
   if(sell_dish<0)
      sell_dish=0;
   if(buy_dish<0)
      buy_dish=0;
}
