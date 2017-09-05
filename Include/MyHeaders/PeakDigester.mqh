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
class PeakDigester : public CriteriaBase
{
   void take_new_bite_buy(double _new_bite);
   void take_new_bite_sell(double _new_bite);
 public:
   double buy_dish,sell_dish;
   virtual double get_advice(bool _for_buy);
   PeakDigester(int _base_weight);
   void take_event(PeakEaterResult _event, double _peak);
};
PeakDigester::PeakDigester(int _base_weight):CriteriaBase(_base_weight)
{
   buy_dish=0; sell_dish=0;
}
double PeakDigester::get_advice(bool _for_buy)
{	//0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   if(_for_buy)
   {	//range of -2 .. +4
      if(buy_dish>=60)
         return 4;
      if(buy_dish>=50)
         return 2;
      if(buy_dish>=40)
         return 1;
      if(buy_dish>=30)
         return 0.4;
      if(buy_dish>=20)
         return 0.2;
      if(buy_dish>=10)
         return 0.1;
      return 0;
   }
   else
   {	//range of -2 .. +4
      if(sell_dish>=60)
         return 4;
      if(sell_dish>=50)
         return 2;
      if(sell_dish>=40)
         return 1;
      if(sell_dish>=30)
         return 0.4;
      if(sell_dish>=20)
         return 0.2;
      if(sell_dish>=10)
         return 0.1;
      return 0;
   }
}
void PeakDigester::take_event(PeakEaterResult _event, double _peak)
{
   double new_bite;
	switch(_event)
	{
		case RESULT_CONFIRM_A:
		   new_bite = _peak-30;
		   take_new_bite_buy(new_bite);
		   if(_peak==99)
		      take_new_bite_sell(0);
			break;
		case RESULT_CONFIRM_V:
		   new_bite = 70-_peak;
		   take_new_bite_sell(new_bite);
		   if(_peak==1)
		      take_new_bite_buy(0);
			break;
		case RESULT_DENY_A:
		case RESULT_DENY_V:
		   if(_peak>30)
   		   take_new_bite_sell(0);
		   if(_peak<70)
   		   take_new_bite_buy(0);
			break;
	}
}
void PeakDigester::take_new_bite_buy(double _new_bite)
{
   buy_dish = (buy_dish*1 + _new_bite)/(1+1);
}
void PeakDigester::take_new_bite_sell(double _new_bite)
{
   sell_dish = (sell_dish*1 + _new_bite)/(1+1);
}
