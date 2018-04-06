//+------------------------------------------------------------------+
//|                                                  BarProfiler.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
class BarProfiler
{
   double open,close,high,low,ave,mid_oc,size,direction;
   double prev_direction;
 public:
   double GetDirection();
   void UpdateData(double open,double close,double high,double low);

   BarProfiler(double _sample);
};

BarProfiler::BarProfiler(double _sample)
{
   prev_direction=0;
   open=_sample;close=_sample;high=_sample;low=_sample;ave=_sample;mid_oc=_sample;
}
double BarProfiler::GetDirection()
{
   return direction;
}
void BarProfiler::UpdateData(double _open,double _close,double _high,double _low)
{
   open=_open;close=_close;high=_high;low=_low;
   ave=(open+close+high+low)/4;
   mid_oc=(open+close)/2;
   size=high-low;
   direction=(open>close)?-1:1;
}
