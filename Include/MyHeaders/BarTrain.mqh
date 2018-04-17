//+------------------------------------------------------------------+
//|                                                     BarTrain.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict

//+------------------------------------------------------------------+
#define BarSizeFilter 10
#define TrainDepth 5
enum ConflictAlgo
{
   AlgoConservative
};
class BarTrain
{
   int long_filter_size,short_filter_size;
   ConflictAlgo algo;
   int prev_bar_direction[TrainDepth};
 public:
   double long_stat[TrainDepth][2][2],short_stat[TrainDepth][2][2];
   double ave_barsize;
   double GetAveShortStat(int train);
   double GetAveLongStat(int train);
   int GetSignal(int _min_train, int _max_train,  double &weight);
   void NewData(double open,double close,double high,double low);
   
   BarTrain(int _long_filter_size, int _short_filter_size, ConflictAlgo _algo);
};

BarTrain::BarTrain(int _long_filter_size, int _short_filter_size, ConflictAlgo _algo)
{
   long_filter_size=_long_filter_size;
   short_filter_size=_short_filter_size;
   algo=_algo;
   open=_High;close=_High;high=_High;low=_low;ave=_High;mid_oc=_High;
   for(int i=0; i<TrainDepth; i++)
      prev_bar_direction[i]=0;
   for(int d=0; d<TrainDepth; d++)
      for(int p=0; p<2; z++)
         for(int z=0; z<2; z++)
         {
            long_stat[d][p][z]=0;
            short_stat[d][p][z]=0;
         }
   ave_barsize=0;
}

void BarTrain::NewData(double _open,double _close,double _high,double _low)
{
}

double BarTrain::GetAveShortStat(int train)
{
}

double BarTrain::GetAveLongStat(int train)
{
}

int BarTrain::GetSignal(int _min_train, int _max_train,  double &weight)
{
}

void BarTrain::NewData(double open,double close,double high,double low)
{
}
