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
 }
 enum PeakEaterResult
 {
 	RESULT_CONFIRM_A,
 	RESULT_CANDIDATE_A,
 	RESULT_CANDIDATE_V,
 	RESULT_CONFIRM_V,
 	RESULT_DENY_A,
 	RESULT_DENY_V,
 	RESULT_CONTINUE
 }
//+------------------------------------------------------------------+
class PeakEater
{
   PeakEaterStatus status;
   double local_max,local_min;
   double get_threshold_A(double _local_max);
   double get_threshold_V(double _local_max);
   void record_A(double _local_max);
   void record_V(double _local_min);
   double V0,V1,V2,A0,A1,A2;
 public:
   PeakEater();
   PeakEaterResult take_sample(double _rsi);
   string get_report();
   int get_buy_peak_order_quality();
   int get_sell_peak_order_quality();
  
};
PeakEater::PeakEater():status(STATUS_RISING),V0(-1),V1(-1),V2(-1),A0(-1),A1(-1),A2(-1),local_max(0),local_min(100)
{
}
PeakEaterResult PeakEater::take_sample(double _rsi)
{
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
				status = STATUS_RISING_STEPDOWN;
				return RESULT_CANDIDATE_A;
			}
			bresk;
		case STATUS_RISING_STEPDOWN:
			if(_rsi<get_threshold_A(local_max))	//already droppped enough
			{
				record_A(local_max);	//report and record the new A
				status = STATUS_FALLING;
				local_min = _rsi;
				return RESULT_CONFIRM_A;
			}
			else 
			if(_rsi<=local_max)
				return RESULT_CANDIDATE_A;
			else
			{
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
				return RESULT_CONFIRM_V;
			}
			else 
			if(_rsi>=local_min)
				return RESULT_CANDIDATE_V;
			else
			{
				local_min=_rsi;
				return RESULT_DENY_V;
			}
			break;
		case STATUS_FALLING:
			if(_rsi<=local_min)	//still falling
			{
				local_min=_rsi;
				return RESULT_CONTINUE;
			}
			else		//step up from local_min
			{
				status = STATUS_FALLING_STEPUP;
				return RESULT_CANDIDATE_V;
			}
			bresk;
	}
}
double PeakEater::get_threshold_A(double _local_max)
{
	if(_local_max>70)
		return _local_max-20;
	if(_local_max>50)
		return _local_max-15;
	if(_local_max>30)
		return _local_max-10;
	else
		return 0;
}
double PeakEater::get_threshold_V(double _local_min)
{
	if(_local_min<30)
		return _local_min+20;
	if(_local_min<50)
		return _local_min+15;
	if(_local_min<70)
		return _local_min+10;
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
int PeakEater::get_buy_peak_order_quality()
{	//range of -2 .. +4
	int desirability = 0;
	if(local_min>=V0)
	{
		desirability ++;
		if(V0>=V1)
			desirability ++;
	}
	else
		desirability --;
	if(A0>=A1)
	{
		desirability ++;
		if(A1>=A2)
			desirability ++;
	}
	else
		desirability --;
	return desirability;
}
int PeakEater::get_sell_peak_order_quality()
{	//range of -2 .. +4
	int desirability = 0;
	if(local_max<=A0)
	{
		desirability ++;
		if(A0<=A1)
			desirability ++;
	}
	else
		desirability --;
	if(V0<=V1)
	{
		desirability ++;
		if(V1<=V2)
			desirability ++;
	}
	else
		desirability --;
	return desirability;
}
