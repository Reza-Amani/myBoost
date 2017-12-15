//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

enum PeakEaterStatus
{
 	STATUS_RISING,
 	STATUS_FALLING
};
enum PeakEaterResult
{
 	RESULT_CONFIRM_A,
 	RESULT_CONFIRM_V,
 	RESULT_CONTINUE
};
//+------------------------------------------------------------------+
class PeakEater
{
   PeakEaterStatus status;
   double local_max,local_min;
   double get_threshold_A(double _local_max);
   double get_threshold_V(double _local_max);
   void record_A(double _local_max);
   void record_V(double _local_min);
   double prev_sample;
 public:
   double V0,V1,V2,A0,A1,A2;
   PeakEater();
   PeakEaterResult take_sample(double _rsi);
   string get_report();
   bool is_rising();
};
PeakEater::PeakEater():status(STATUS_RISING),V0(-1),V1(-1),V2(-1),A0(-1),A1(-1),A2(-1),local_max(0),local_min(100),prev_sample(50)
{
}
bool PeakEater::is_rising()
{
   return status==STATUS_RISING;
}
PeakEaterResult PeakEater::take_sample(double _rsi)
{
   double rsi1=prev_sample;
   prev_sample=_rsi;
	switch(status)
	{
		case STATUS_RISING:
			if(_rsi>=local_max)	//still rising
			{
				local_max=_rsi;
				return RESULT_CONTINUE;
			}
			else		//step down from local_max
			{
				status = STATUS_FALLING;
				record_A(local_max);	//report and record the new A
				local_min = _rsi;
				return RESULT_CONFIRM_A;
			}
			break;
		case STATUS_FALLING:
			if(_rsi<=local_min)	//still falling
			{
				local_min=_rsi;
				return RESULT_CONTINUE;
			}
			else		//step down from local_max
			{
				status = STATUS_RISING;
				record_V(local_min);	//report and record the new V
				local_max = _rsi;
				return RESULT_CONFIRM_V;
			}
			break;
		default:
		   return RESULT_CONTINUE;
	}
}
double PeakEater::get_threshold_A(double _local_max)
{
	if(_local_max>70)
		return _local_max-20;
	if(_local_max>50)
		return _local_max-12;
	if(_local_max>30)
		return _local_max-8;
	else
		return 0;
}
double PeakEater::get_threshold_V(double _local_min)
{
	if(_local_min<30)
		return _local_min+20;
	if(_local_min<50)
		return _local_min+12;
	if(_local_min<70)
		return _local_min+8;
	else
		return 100;
}
void PeakEater::record_A(double _local_max)
{
	A2=A1;
	A1=A0;
	A0=_local_max;
}
void PeakEater::record_V(double _local_min)
{
	V2=V1;
	V1=V0;
	V0=_local_min;
}
string PeakEater::get_report()
{
	string str="";
	str+="PeakEater: V2="+IntegerToString((int)V2)+" A2="+IntegerToString((int)A2)+" V1="+IntegerToString((int)V1)+" A1="+IntegerToString((int)A1)+" V0="+IntegerToString((int)V0)+" A0="+IntegerToString((int)A0);
	return str;
}
