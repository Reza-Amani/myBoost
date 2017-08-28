//+------------------------------------------------------------------+
//|                                              DesSwingQuality.mqh |
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
//TODO: idea: CritEvaluate class; to keep the pointer and dynamic w and results
class DynamicEvaluator
{
private:
   CriteriaEvaluate crit_eval1,criteval2;
public:
   DynamicEvaluator(DesirabilityCriteriaBase* _crit1, int _baseW1);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DynamicEvaluator::DynamicEvaluator(DesirabilityCriteriaBase* _crit1, int _baseW1)
{
   crit_eval1.set(_crit1,_baseW1);
//   crit_eval1.
//   crit1=_crit1;
//   w1=(crit1!=NULL)?_baseW1:0;
}
