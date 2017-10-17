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
 	STATUS_RISING_STEPDOWN,
 	STATUS_FALLING_STEPUP,
 	STATUS_FALLING
};
enum PeakEaterResult
{
 	RESULT_CONFIRM_A,
 	RESULT_CANDIDATE_A,
 	RESULT_CANDIDATE_V,
 	RESULT_CONFIRM_V,
 	RESULT_DENY_A,
 	RESULT_DENY_V,
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
   bool fast_peak;
   PeakEater(bool _fast_peak);
   PeakEaterResult take_sample(double _rsi, double& _new_peak);
   string get_report();
};
PeakEater::PeakEater(bool _fast_peak):status(STATUS_RISING),V0(-1),V1(-1),V2(-1),A0(-1),A1(-1),A2(-1),local_max(0),local_min(100),prev_sample(50),fast_peak(_fast_peak)
{
}
PeakEaterResult PeakEater::take_sample(double _rsi, double& _new_peak)
{
   double rsi1=prev_sample;
   prev_sample=_rsi;
   if(fast_peak)
   	switch(status)
   	{
   		case STATUS_RISING:
   			if(_rsi>=local_max)	//still rising
   			{
   				local_max=_rsi;
   				_new_peak = _rsi;
   				return RESULT_CONTINUE;
   			}
   			else		//step down from local_max
   			{
   				status = STATUS_FALLING;
   				_new_peak = local_max;
   				record_A(local_max);	//report and record the new A
   				local_min = _rsi;
   				return RESULT_CONFIRM_A;
   			}
   			break;
   		case STATUS_FALLING:
   			if(_rsi<=local_min)	//still falling
   			{
   				local_min=_rsi;
   				_new_peak = _rsi;
   				return RESULT_CONTINUE;
   			}
   			else		//step down from local_max
   			{
   				status = STATUS_RISING;
   				_new_peak = local_min;
   				record_V(local_min);	//report and record the new V
   				local_max = _rsi;
   				return RESULT_CONFIRM_V;
   			}
   			break;
   		default:
   		   return RESULT_CONTINUE;
   	}
	else
   	switch(status)
   	{
   		case STATUS_RISING:
   			if(_rsi>=local_max)	//still rising
   			{
   				local_max=_rsi;
   				_new_peak = _rsi;
   				return RESULT_CONTINUE;
   			}
   			else		//step down from local_max
   			{
   				status = STATUS_RISING_STEPDOWN;
   				_new_peak = local_max;
   				return RESULT_CANDIDATE_A;
   			}
   			break;
   		case STATUS_RISING_STEPDOWN:
   			if(_rsi<get_threshold_A(local_max))	//already droppped enough
   			{
   				record_A(local_max);	//report and record the new A
   				status = STATUS_FALLING;
   				local_min = _rsi;
   				_new_peak = local_max;
   				return RESULT_CONFIRM_A;
   			}
   			else 
   			if(_rsi<=local_max)
   			{
   				_new_peak = local_max;
   				if(_rsi<rsi1)
      				return RESULT_CANDIDATE_A;
      		   else
      		      return RESULT_CONTINUE;
   			}
   			else
   			{
     				status = STATUS_RISING;
     				_new_peak=local_max; //send the local max instead of new peak, to check over 70 
   				local_max=_rsi;
   				return RESULT_DENY_A;
   			}
   			break;
   		case STATUS_FALLING_STEPUP:
   			if(_rsi>get_threshold_V(local_min))	//already rose enough
   			{
   				record_V(local_min);	//report and record the new V
   				status = STATUS_RISING;
   				local_max = _rsi;
   				_new_peak = local_min;
   				return RESULT_CONFIRM_V;
   			}
   			else 
   			if(_rsi>=local_min)
   			{
   			   _new_peak = local_min;
   				if(_rsi>rsi1)
      				return RESULT_CANDIDATE_V;
      		   else
      		      return RESULT_CONTINUE;
   			}
   			else
   			{
     				status = STATUS_FALLING;
     				_new_peak=local_min; //send the local min instead of new peak, to check under 30 
   				local_min=_rsi;
   				return RESULT_DENY_V;
   			}
   			break;
   		case STATUS_FALLING:
   			if(_rsi<=local_min)	//still falling
   			{
   				local_min=_rsi;
   				_new_peak=_rsi;
   				return RESULT_CONTINUE;
   			}
   			else		//step up from local_min
   			{
   				status = STATUS_FALLING_STEPUP;
   				return RESULT_CANDIDATE_V;
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
	str+="DBG: PeakEater: V2="+IntegerToString((int)V2)+" A2="+IntegerToString((int)A2)+" V1="+IntegerToString((int)V1)+" A1="+IntegerToString((int)A1)+" V0="+IntegerToString((int)V0)+" A0="+IntegerToString((int)A0);
	return str;
}
