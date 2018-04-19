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
enum ConflictAlgo
{
   AlgoConservative
};
class BarTrain
{
   MyMath math;
   int long_filter_size,short_filter_size;
   ConflictAlgo algo;
   double threshold;
   int prev_bar_direction[TrainDepth];
   int CalculateTrainLen();
   void ShiftBarDirHistory(int _new_dir);
 public:
   double long_stat[TrainDepth][2][2],short_stat[TrainDepth][2][2];
   double long_stat_total[TrainDepth],short_stat_total[TrainDepth];
   int long_stat_total_hit[TrainDepth],short_stat_total_hit[TrainDepth];
   double ave_barsize;
   double GetAveShortStat(int train);
   double GetAveLongStat(int train);
   int GetSignal(int _min_train, int _max_train,  double &weight);
   void NewData(double open,double close,double high,double low);
   
   BarTrain(int _long_filter_size, int _short_filter_size, ConflictAlgo _algo, double _thresh);
};

BarTrain::BarTrain(int _long_filter_size, int _short_filter_size, ConflictAlgo _algo, double _thresh)
{
   long_filter_size=_long_filter_size;
   short_filter_size=_short_filter_size;
   algo=_algo; threshold=_thresh;
   for(int i=0; i<TrainDepth; i++)
   {
      prev_bar_direction[i]=0;
      long_stat_total[i]=0;
      long_stat_total_hit[i]=0;
      short_stat_total[i]=0;
      short_stat_total_hit[i]=0;
   }
   for(int d=0; d<TrainDepth; d++)
      for(int p=0; p<2; p++)
         for(int z=0; z<2; z++)
         {
            long_stat[d][p][z]=0;
            short_stat[d][p][z]=0;
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
   int new_bar_size = (_high-_low>ave_barsize) ? 1 : 0;
   int new_bar_shape;
   if(new_bar_direction==1)
      new_bar_shape = (_close>=(_high+_low)/2) ? 1 : 0;
   else
      new_bar_shape = (_close<=(_high+_low)/2) ? 1 : 0;

   int continue_or_reversed = prev_bar_direction[0]*new_bar_direction;
   long_stat[train_len][new_bar_shape][new_bar_size] = (long_stat[train_len][new_bar_shape][new_bar_size] * long_filter_size + continue_or_reversed) / (long_filter_size+1);
   short_stat[train_len][new_bar_shape][new_bar_size] = (short_stat[train_len][new_bar_shape][new_bar_size] * short_filter_size + continue_or_reversed) / (short_filter_size+1);
   long_stat_total_hit[train_len]++;
   short_stat_total_hit[train_len]++;
   long_stat_total[train_len] = (long_stat_total[train_len] * long_filter_size +  continue_or_reversed) / (long_filter_size+1);
   short_stat_total[train_len] = (short_stat_total[train_len] * short_filter_size +  continue_or_reversed) / (short_filter_size+1);
   ave_barsize = (ave_barsize*BarSizeFilter + _high-_low) / (BarSizeFilter+1);
   ShiftBarDirHistory(new_bar_direction);
}

double BarTrain::GetAveShortStat(int _train)
{
   double ave=0;
   for(int p=0; p<2; p++)
      for(int z=0; z<2; z++)
         ave+=short_stat[_train][p][z];
   ave=ave/4;
   return ave;
}

double BarTrain::GetAveLongStat(int _train)
{
   double ave=0;
   for(int p=0; p<2; p++)
      for(int z=0; z<2; z++)
         ave+=long_stat[_train][p][z];
   ave=ave/4;
   return ave;
}

int BarTrain::GetSignal(int _min_train, int _max_train,  double &weight)
{
   switch(algo)
   {
      case AlgoConservative:
         if(GetAveLongStat(0)>threshold && GetAveShortStat(0)>threshold)
         {
            weight = GetAveLongStat(0);
            return prev_bar_direction[0];
         }
   }
   return 0;
}
