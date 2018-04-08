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
   Pred_History3_N,
   Pred_History2_N,
   Pred_History1_N,
   Pred_History0_N,
   Pred_OnlyDir_N,
   Pred_OnlyDir_P,
   Pred_History0_P,
   Pred_History1_P,
   Pred_History2_P,
   Pred_History3_P,
   Pred_size
};
class BarProfiler
{
   double open,close,high,low,ave,mid_oc,size;
   int prev_direction,prev_prev_direction,direction;
   int filter_size;
 public:
   double quality[Pred_size];
   int GetDirection();
   int GetHistory();
   void UpdateResult(int _result_dir);
   void UpdateData(double open,double close,double high,double low);
   void UpdatePrevData(int prevdir, int prevprevdir);
   
   int GetPred(BarPredRule _rule);
   BarPredRule GetBestRule();
   BarPredRule GetFirstGood();

   BarProfiler(double _sample, int _filter);
};

BarProfiler::BarProfiler(double _sample, int _filter)
{
   prev_direction=0;prev_prev_direction=0;
   open=_sample;close=_sample;high=_sample;low=_sample;ave=_sample;mid_oc=_sample;
   for(int i=0; i<Pred_size; i++)
      quality[i]=0;
   filter_size = _filter;
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
   for(int i=0; i<Pred_size; i++)
   {
      int outcome = GetPred((BarPredRule)i)*_result_dir;
      quality[i] = (quality[i]*filter_size + outcome)/(filter_size+1);
   }
}
int BarProfiler::GetPred(BarPredRule _rule)
{
   switch(_rule)
   {
      case Pred_OnlyDir_N:
         return -direction;
      case Pred_OnlyDir_P:
         return +direction;
      case Pred_History0_N:
         if(GetHistory()==0)
            return -direction;
         else
            return 0;
      case Pred_History0_P:
         if(GetHistory()==0)
            return +direction;
         else
            return 0;
      case Pred_History1_N:
         if(GetHistory()==1)
            return -direction;
         else
            return 0;
      case Pred_History1_P:
         if(GetHistory()==1)
            return +direction;
         else
            return 0;
      case Pred_History2_N:
         if(GetHistory()==2)
            return -direction;
         else
            return 0;
      case Pred_History2_P:
         if(GetHistory()==2)
            return +direction;
         else
            return 0;
      case Pred_History3_N:
         if(GetHistory()==3)
            return -direction;
         else
            return 0;
      case Pred_History3_P:
         if(GetHistory()==3)
            return +direction;
         else
            return 0;

         
      default:
         return 0;
   }
}
BarPredRule BarProfiler::GetBestRule()
{
   int maxi=0;
   double maxPred=-1;;
   for(int i=0; i<Pred_size; i++)
   {
      if(quality[i]>maxPred)
      {
         maxPred=quality[i];
         maxi=i;
      }
   }
   return (BarPredRule)maxi;
}
BarPredRule BarProfiler::GetFirstGood()
{
   int i;
   for(i=0; i<Pred_size; i++)
   {
      if(quality[i]>0)
         return (BarPredRule)i;
   }
   return Pred_size;
}