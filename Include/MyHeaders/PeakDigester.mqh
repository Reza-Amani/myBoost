//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
class PeakDigester
{
   double buy_dish,sell_dish;
   void take_new_bite_buy(double _new_bite);
   void take_new_bite_sell(double _new_bite);
 public:
   PeakDigester();
   void take_event(PeakEaterResult _event, double _peak);
   double get_buy_dish();
   double get_sell_dish();
 
};
PeakDigester::PeakDigester():buy_dish(0),sell_dish(0)
{
}
void PeakDigester::take_event(PeakEaterResult _event, double _peak)
{
   double new_bite;
	switch(_event)
	{
		case RESULT_CONFIRM_A:
		   new_bite = _peak-30;
		   take_new_bite_buy(new_bite);
			break;
		case RESULT_CONFIRM_V:
		   new_bite = 70-_peak;
		   take_new_bite_sell(new_bite);
			break;
		case RESULT_DENY_A:
		case RESULT_DENY_V:
		   take_new_bite_buy(0);
		   take_new_bite_sell(0);
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
double PeakDigester::get_buy_dish()
{
   return buy_dish;
}
double PeakDigester::get_sell_dish()
{
   return sell_dish;
}
