//+------------------------------------------------------------------+
//|                                                     BarTrain.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

#include <MyHeaders/Tools/MyMath.mqh>
//+------------------------------------------------------------------+
#define BarSizeFilter 10
#define TrainDepth 5
enum AlgoOpen
{
   Algo_Conservative,
   Algo_TestSingle
};
enum AlgoClose
{
   AlgoClose_No,
   AlgoClose_Conservative,
   AlgoClose_Aggressive
};
class BarTrain
{
   MyMath math;
   int long_filter_size,short_filter_size;
   AlgoOpen algo;
   AlgoClose algo_close;
   double threshold_short, threshold_long;
   int last_bar_shape;
   int prev_bar_direction[TrainDepth];
   int CalculateTrainLen();
   void ShiftBarDirHistory(int _new_dir);
 public:
   double long_stat[TrainDepth][2],short_stat[TrainDepth][2];
   double ave_barsize;
   int GetSignal(int _min_train, int _max_train,  double &weight, int _algo_par0, int _algo_par1, int _algo_par2);
   void NewData(double open,double close,double high,double low);
   bool IsKeepable();
   
   BarTrain(int _long_filter_size, int _short_filter_size, AlgoOpen _algo, AlgoClose _algo_close, double _thresh_short, double _thresh_long);
};

BarTrain::BarTrain(int _long_filter_size, int _short_filter_size, AlgoOpen _algo, AlgoClose _algo_close, double _thresh_short, double _thresh_long)
{
   long_filter_size=_long_filter_size;
   short_filter_size=_short_filter_size;
   algo=_algo; algo_close=_algo_close; threshold_short=_thresh_short; threshold_long = _thresh_long;
   for(int i=0; i<TrainDepth; i++)
      prev_bar_direction[i]=0;
   for(int d=0; d<TrainDepth; d++)
      for(int p=0; p<2; p++)
      {
         long_stat[d][p]=0;
         short_stat[d][p]=0;
      }
   ave_barsize=0;
}

int BarTrain::CalculateTrainLen()
{
   int len=0;
   for(int i=1; i<TrainDepth; i++)
      if(prev_bar_direction[i]==prev_bar_direction[0])
         len++;
      else
         break;
   return len;
}

void BarTrain::ShiftBarDirHistory(int _new_dir)
{
   for(int i=TrainDepth-1; i>0; i--)
      prev_bar_direction[i] = prev_bar_direction[i-1];
   prev_bar_direction[0]=_new_dir;
}

void BarTrain::NewData(double _open,double _close,double _high,double _low)
{
   int new_bar_direction=math.sign(_close-_open);
   int train_len=CalculateTrainLen();

   int continue_or_reversed = prev_bar_direction[0]*new_bar_direction;
   long_stat[train_len][last_bar_shape] = (long_stat[train_len][last_bar_shape] * long_filter_size + continue_or_reversed) / (long_filter_size+1);
   short_stat[train_len][last_bar_shape] = (short_stat[train_len][last_bar_shape] * short_filter_size + continue_or_reversed) / (short_filter_size+1);
   ave_barsize = (ave_barsize*BarSizeFilter + _high-_low) / (BarSizeFilter+1);
   
   ShiftBarDirHistory(new_bar_direction);

   if(new_bar_direction==1)
      last_bar_shape = (_close>=(_high+_low)/2) ? 1 : 0;
   else
      last_bar_shape = (_close<=(_high+_low)/2) ? 1 : 0;
}

int BarTrain::GetSignal(int _min_train, int _max_train,  double &weight, int _algo_par0, int _algo_par1, int _algo_par2)
{
   switch(algo)
   {
      case Algo_Conservative:
         return 0;
         break;
      case Algo_TestSingle:
         if(CalculateTrainLen()==_algo_par0)
            if(last_bar_shape == _algo_par1)
               return -prev_bar_direction[0];
         break;
   }
   return 0;
}

bool BarTrain::IsKeepable()
{
   switch(algo_close)
   {
      case AlgoClose_No:
         return false;
         break;
      case AlgoClose_Conservative:
         if(short_stat[CalculateTrainLen()][last_bar_shape]>0 && long_stat[CalculateTrainLen()][last_bar_shape]>0)
            return true;
         else 
            return false;
         break;
      case AlgoClose_Aggressive:
         if(short_stat[CalculateTrainLen()][last_bar_shape] + long_stat[CalculateTrainLen()][last_bar_shape] >0)
            return true;
         else 
            return false;
         break;
   }
   return false;
}
