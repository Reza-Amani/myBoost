//+------------------------------------------------------------------+
//|                                     DesirabilityCriteriaBase.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CriteriaBase
{
private:
	int base_weight;
	int dynamic_weight;

public:
   CriteriaBase(int _base_weight);
   double get_advice(bool _for_buy);	//virtual, 0(veto), 0.1,0.2,..1(neutral),2,3,4
   void update_opened(bool _buy);
   void update_result(bool _profitable);
   string get_report();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CriteriaBase::CriteriaBase(int _base_weight):base_weight(_base_weight)
{
}
void CriteriaBase::update_opened(bool _buy)
{
	//call get_advice and record the suggestion internally
}
void CriteriaBase::update_result(bool _profitable)
{
	//compare to the suggestion and update the ongoing result and dynamic weight
}
string CriteriaBase::get_report()
{
	
}
