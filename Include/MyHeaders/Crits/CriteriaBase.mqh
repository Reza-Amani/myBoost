//+------------------------------------------------------------------+
//|                                     DesirabilityCriteriaBase.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include <MyHeaders\Tools\MyMath.mqh>
#include <MyHeaders\Operations\PeakEater.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CriteriaBase
{
private:
	int base_weight;
	int dynamic_weight;
	int did_agree;
	double accumulated_advice;
	double net_good_advice;

	MyMath math;

public:
   CriteriaBase(int _base_weight);
   virtual double get_advice(bool _for_buy, int i);	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   virtual void take_input(PeakEaterResult _event, double _rsi);
   virtual void take_input(double _V0,double _V1, double _V2,double _A0 ,double _A1,double _A2);
   virtual void take_input(int i);

   void update_opened(bool _buy, int i);
   void update_result(bool _profitable);
   int get_advice_percent();
   string get_report();
	int signed_advice(double _advice);	//re-scale the advice to -5(veto),-4,-2,-1,0,1,2,4
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CriteriaBase::CriteriaBase(int _base_weight):base_weight(_base_weight)
{
	accumulated_advice=1; net_good_advice=0;
}
void CriteriaBase::update_opened(bool _buy, int i)
{	//call get_advice and record the suggestion internally
	did_agree = signed_advice(get_advice(_buy, i));
}
int CriteriaBase::signed_advice(double _advice)
{	//re-scale the advice to -5(veto),-4,-2,-1,0,1,2,4
	if(_advice==0)
		return -5;
	if(_advice<=0.1)
		return -4;
	if(_advice<=0.2)
		return -2;
	if(_advice<=0.4)
		return -1;
	if(_advice<=1)
		return 0;
	if(_advice<=2)
		return +1;
	if(_advice<=4)
		return +2;
	if(_advice<=8)
		return +4;
	else
		return -6;	//unknown advice
}
void CriteriaBase::update_result(bool _profitable)
{	//compare to the suggestion and update the ongoing result and dynamic weight
 	
 	accumulated_advice+= math.abs(did_agree);
	if(_profitable)
		net_good_advice += did_agree;
	else
		net_good_advice -= did_agree;
}

int CriteriaBase::get_advice_percent()
{
	return (int) (net_good_advice/accumulated_advice);
}

string CriteriaBase::get_report()
{
	string str="";
	str+="CritBase:"+IntegerToString(1);
	return str;

}
