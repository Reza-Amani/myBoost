//+------------------------------------------------------------------+
//|                                                      Pattern.mqh |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property strict

#include <MyHeaders\MyMath.mqh>

enum CorrelationBase
{
   CORREL_CLOSE,
   CORREL_HLC,
   CORREL_HC0LC0,
   CORREL_HLS
};

#define cont    FileSeek(file_handle,-2,SEEK_CUR)

class Pattern
{
  public:
   Pattern();
   Pattern(const double &_high[],const double &_low[],const double &_close[],int _src_start, int _size, double _f_close1, double _f_high1, double _f_low1,CorrelationBase _corr_base);
   int size;
   CorrelationBase corr_base;
   double close[],high[],low[],highc0[],lowc0[],bar_size[];
   double fc1,fh1,fl1,ac1,aH1,aL1;
   double absolute_diffs;
   void set_data(const double &_high[],const double &_low[],const double &_close[],int _src_start, int _size, double _f_close1, double _f_high1, double _f_low1, CorrelationBase _corr_base);
   void log_to_file(int file_handle);
   int operator&(const Pattern &p2)const;
   int operator&&(const Pattern &p2)const;
  private:
   double calculate_absolute_diff();
};
int Pattern::operator&&(const Pattern &p2)const
{  //correlation
   int result;
   switch(corr_base)
   {
      case CORREL_CLOSE:
         return MyMath::correlation_array(close,0,p2.close,0,size);
         break;
      case CORREL_HLC:
         result=MyMath::correlation_array(close,0,p2.close,0,size);
         result+=MyMath::correlation_array(high,0,p2.high,0,size);
         result+=MyMath::correlation_array(low,0,p2.low,0,size);
         result=result/3;
         return result;
         break;
      case CORREL_HC0LC0:
         result=MyMath::correlation_array(highc0,0,p2.highc0,0,size+1);
         result+=MyMath::correlation_array(lowc0,0,p2.lowc0,0,size+1);
         return result/2;
         break;
      case CORREL_HLS:
         result=MyMath::correlation_array(bar_size,0,p2.bar_size,0,size);
         result+=MyMath::correlation_array(high,0,p2.high,0,size);
         result+=MyMath::correlation_array(low,0,p2.low,0,size);
         result=result/3;
         return result;
         break;
      default:
         return 0;
      
   }
}
double Pattern::calculate_absolute_diff()
{  
  double result=0;
   for(int i=0;i<size-1;i++)
   {
      result+=MathAbs(close[i]-close[i+1]);
   }
   result/=(size-1);
   return result;
}
void Pattern::log_to_file(int file_handle)
{
   FileWrite(file_handle,"","close");
   for(int i=0;i<size;i++)
   {
      cont;
      FileWrite(file_handle,"",close[i]);
   }  
   cont;
   FileWrite(file_handle,"","diff",absolute_diffs);
   cont;
//   FileWrite(file_handle,"","fc1ac1",fc1,ac1);
   FileWrite(file_handle,"","fh1fc1",fh1,fc1);
}
Pattern::Pattern(const double &_high[],const double &_low[],const double &_close[],int _src_start,int _size, double _f_close1, double _f_high1, double _f_low1,CorrelationBase _corr_base)
{
   set_data( _high, _low, _close, _src_start, _size, _f_close1, _f_high1, _f_low1, _corr_base);
}
Pattern::Pattern(void)
{
}
void Pattern::set_data(const double &_high[],const double &_low[],const double &_close[],int _src_start, int _size, double _f_close1, double _f_high1, double _f_low1,CorrelationBase _corr_base)
{
   size = _size;
   fc1=_f_close1;
   fh1=_f_high1;
   fl1=_f_low1;
   corr_base=_corr_base;
   ArrayResize(close,size);
   ArrayCopy(close,_close,0,_src_start,size);
   ArrayResize(high,size);
   ArrayCopy(high,_high,0,_src_start,size);
   ArrayResize(highc0,size+1);
   ArrayCopy(highc0,_high,1,_src_start,size);
   highc0[0]=close[0];
   ArrayResize(lowc0,size+1);
   ArrayCopy(lowc0,_low,1,_src_start,size);
   lowc0[0]=close[0];
   ArrayResize(low,size);
   ArrayCopy(low,_low,0,_src_start,size);
   
   ArrayResize(bar_size,size);
   for(int i=0; i<size; i++)
      bar_size[i]=high[i]-low[i];

   absolute_diffs = calculate_absolute_diff();
   if(absolute_diffs!=0)
   {
      aH1=(_f_high1-close[0])/absolute_diffs;
      aL1=(_f_low1-close[0])/absolute_diffs;
      ac1=(fc1-close[0])/absolute_diffs;
   }
   else
   {
      aH1=0;
      ac1=0;
      aL1=0;
   }
}
