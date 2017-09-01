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

 public:
   PeakDigester();
 
};
PeakDigester::PeakDigester()
{
}
void PeakDigester::take_event(PeakEaterResult, int _peak)
{
	switch(PeakEaterResult)
	{
		case RESULT_CONFIRM_A:
			break;
		case RESULT_CONFIRM_V:
			break;
		case RESULT_DENY_A:
		case RESULT_DENY_V:
			break;
	}
}