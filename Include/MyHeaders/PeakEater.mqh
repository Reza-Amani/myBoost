//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
class PeakEater
{
   bool looking_for_A;
   double local_max,local_min;
   double get_threshold_A(double _local_max);
   double get_threshold_V(double _local_max);
   void record_A(double _local_max);
   void record_V(double _local_min);
 public:
   double V0,V1,V2,A0,A1,A2;
   PeakEater();
   int take_sample(double _rsi);
   string get_report();
  
};
PeakEater::PeakEater():looking_for_A(true),V0(-1),V1(-1),V2(-1),A0(-1),A1(-1),A2(-1),local_max(0),local_min(100)
{
}
int PeakEater::take_sample(double _rsi)
{
	if(looking_for_A)
	{
		if(_rsi>=local_max)	//still rising
			local_max=_rsi;
		else		//step down from local_max
			if(_rsi<get_threshold_A(local_max))	//already droppped enough
			{
				record_A(local_max);	//report and record the new A
				looking_for_A = false;
				local_min = 100;
				if(A2>0 && B2>0)
					return +1;
			}
	}
	else	//looking for V
	{
		if(_rsi<=local_min)	//still falling
			local_min=_rsi;
		else		//step up from local_min
			if(_rsi>get_threshold_V(local_min))	//already jumped enough
			{
				record_V(local_min);	//report and record the new V
				looking_for_A = true;
				local_max = 0;
				if(A2>0 && B2>0)
					return -1;
			}
	}
	return 0;
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
	str+="DBG: PeakEater: V2="+IntToString((int)V2)+" A2="+IntToString((int)A2)+" V1="+IntToString((int)V1)+" A1="+IntToString((int)A1)+" V0="+IntToString((int)V0)+" A0="+IntToString((int)A0);
	return str;
}