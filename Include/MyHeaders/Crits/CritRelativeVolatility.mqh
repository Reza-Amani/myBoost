//+------------------------------------------------------------------+
//|                                             money_management.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

#include <MyHeaders\Crits\CriteriaBase.mqh>

//+------------------------------------------------------------------+
class RelativeVolatility : public CriteriaBase
{
 private:
   int len;
 public:
   RelativeVolatility(int _base_weight, int _len);
   virtual double get_advice(bool _for_buy);	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   virtual void take_input();
   double get_volatility(int _shift);
};
RelativeVolatility::RelativeVolatility(int _base_weight, int _len):CriteriaBase(_base_weight),len(_len)
{
}
double RelativeVolatility::get_volatility(int _shift)
{
   int i;
   double maxC=0,minC=100,aveSize=0;
   for(i=_shift;i<len+_shift;i++)
   {
      if(Close[i]>maxC)
         maxC=Close[i];
      if(Close[i]<minC)
         minC=Close[i];
      aveSize+= High[i]-Low[i];
   }
   if(aveSize==0)
      return 0;
   return len*(maxC-minC)/aveSize;
}
double RelativeVolatility::get_advice(bool _for_buy)
{	//0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   double volat = get_volatility(0);
   if(volat>10)
      return 2;
   else 
      return 0.4;
}
void RelativeVolatility::take_input()
{
}
