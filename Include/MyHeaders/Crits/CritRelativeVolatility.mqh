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
   RelativeVolatility(int _base_weight);
   virtual double get_advice(bool _for_buy);	//virtual, 0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   virtual void take_input();
   double get_volatility();
};
RelativeVolatility::RelativeVolatility(int _base_weight, int _len):CriteriaBase(_base_weight),len(_len)
{
}
double RelativeVolatility::get_volatility(void)
{
   int i;
   double maxH=0,minL=100,aveSize=0;
   for(i=0;i<len;i++)
   {
      if(High[i]>maxH)
         maxH=High[i];
      if(Low[i]<minL)
         minL=Low[i];
      aveSize+= High[i]-Low[i];
   }
   if(aveSize==0)
      return 0;
   return volatility = len*(maxH-minL)/aveSize;
}
double RelativeVolatility::get_advice(bool _for_buy)
{	//0(veto), 0.1,0.2,0.4,1(neutral),2,4,8
   double volatility = get_volatility();
   if(volatility>20)
      return 4;
   else if(volatility>10)
      return 2;
   else if(volatility>5)
      return 1;
   else if(volatility>3)
      return 0.4;
   else if(volatility>2)
      return 0.2;
   else if(volatility>1)
      return 0.1;
   else 
      return 0;
}
void RelativeVolatility::take_input()
{
}
