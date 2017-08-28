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
class CriteriaEvaluate : public DesirabilityCriteriaBase
{
private:

public:
   CriteriaEvaluate();
   int weight;
   DesirabilityCriteriaBase* criteria;
   void set(DesirabilityCriteriaBase* _criteria, int _baseW);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CriteriaEvaluate::CriteriaEvaluate()
{
}
CriteriaEvaluate::set(DesirabilityCriteriaBase* _criteria, int _baseW)
{
   criteria = _criteria;
   weight = _baseW;
}
