//+------------------------------------------------------------------+
//|                                                      Pattern.mqh |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property strict

#include <MyHeaders\MyMath.mqh>

#define cont    FileSeek(file_handle,-2,SEEK_CUR)

class Pattern
{
  public:
   Pattern();
   Pattern(const double &_src[],int _src_start, int _size, double _f_close1);
   int size;
   double close[];
   double fc1,ac1;
   double absolute_diffs;
   void set_data(const double &_src[],int _src_start, int _size, double _f_close1);
   void log_to_file(int file_handle);
   int operator&(const Pattern &p2)const;
  private:
   double calculate_absolute_diff();
};
int Pattern::operator&(const Pattern &p2)const
{  //correlation
   return MyMath::correlation_array(close,0,p2.close,0,size);
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
   FileWrite(file_handle,"","fc1ac1",fc1,ac1);
}
Pattern::Pattern(const double &_src[],int _src_start,int _size, double _f_close1)
{
   set_data(_src,_src_start,_size,_f_close1);
}
Pattern::Pattern(void)
{
}
void Pattern::set_data(const double &_src[],int _src_start, int _size, double _f_close1)
{
   size = _size;
   fc1=_f_close1;
   ArrayResize(close,size);
   ArrayCopy(close,_src,0,_src_start,size);
   absolute_diffs = calculate_absolute_diff();
   if(absolute_diffs!=0)
      ac1=(fc1-close[0])/absolute_diffs;
   else
      ac1=0;
}
