//+------------------------------------------------------------------+
//|                                                  BarProfiler.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
enum BarPredRule
{
   Pred_OnlyDir
};
class BarProfiler
{
   double open,close,high,low,ave,mid_oc,size;
   int prev_direction,prev_prev_direction,direction;
 public:
   int GetDirection();
   int GetHistory();
   void UpdateResult(int _result_dir);
   void UpdateData(double open,double close,double high,double low);
   void UpdatePrevData(int prevdir, int prevprevdir);
   
   int GetPred(BarPredRule _rule);

   BarProfiler(double _sample);
};

BarProfiler::BarProfiler(double _sample)
{
   prev_direction=0;prev_prev_direction=0;
   open=_sample;close=_sample;high=_sample;low=_sample;ave=_sample;mid_oc=_sample;
}
int BarProfiler::GetHistory()
{
   int temp=0;
   if(prev_direction==direction)
      temp+=1;
   if(prev_prev_direction==direction)
      temp+=2;
   return temp;
}
int BarProfiler::GetDirection()
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
void BarProfiler::UpdatePrevData(int _prevdir, int _prevprevdir)
{
   prev_direction=_prevdir;
   prev_prev_direction=_prevprevdir;
}
void BarProfiler::UpdateResult(int _result_dir)
{
}
int BarProfiler::GetPred(BarPredRule _rule)
{
   switch(_rule)
   {
      case Pred_OnlyDir:
         return -direction;
      default:
         return 0;
   }
}
