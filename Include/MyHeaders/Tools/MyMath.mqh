//+------------------------------------------------------------------+
//|                                                       MyMath.mqh |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property strict

#include <MyHeaders\Tools\Tools.mqh>

/////////////////////////////////////////////////////////////////class
class MyMath
{
  public:
   static double max(double v1,double v2=-DBL_MAX,double v3=-DBL_MAX,double v4=-DBL_MAX,double v5=-DBL_MAX,double v6=-DBL_MAX);
   static double min(double v1,double v2=DBL_MAX,double v3=DBL_MAX,double v4=DBL_MAX,double v5=DBL_MAX,double v6=DBL_MAX);
   static double cap(double in,double _max,double _min);
   static int sign(double in);
   static double abs(double in);
   static int correlation_array(const double &array1[],int offset1,const double &array2[],int offset2,int _len);
};
int MyMath::correlation_array(const double &array1[],int offset1,const double &array2[],int offset2,int _len)
{
//sigma(x-avgx)(y-avgy)/sqrt(sigma(x-avgx)2*sigma(y-avgy)2)
   double x,y;
   double avg1=0,avg2=0;
   int i;
   for(i=0; i<_len; i++)
   {
      x = array1[i+offset1];
      y = array2[i+offset2];
      avg1 += x;
      avg2 += y;
   }
   avg1 /= _len;
   avg2 /= _len;

   double x_xby_yb=0,x_xb2=0,y_yb2=0;
   for(i=0; i<_len; i++)
   {
      x = array1[i+offset1];
      y = array2[i+offset2];
      x_xby_yb+=(x-avg1)*(y-avg2);
      x_xb2 += (x-avg1)*(x-avg1);
      y_yb2 += (y-avg2)*(y-avg2);
   }

   if(x_xb2*y_yb2==0)
      return 0;

   return (int)((double)100*x_xby_yb/MathSqrt(x_xb2 * y_yb2));
}

double MyMath::max(double v1,double v2=-DBL_MAX,double v3=-DBL_MAX,double v4=-DBL_MAX,double v5=-DBL_MAX,double v6=-DBL_MAX)
{
   double result=v1;
   if(v2>result)  result=v2;
   if(v3>result)  result=v3;
   if(v4>result)  result=v4;
   if(v5>result)  result=v5;
   if(v6>result)  result=v6;
   return result;
}
double MyMath::min(double v1,double v2=DBL_MAX,double v3=DBL_MAX,double v4=DBL_MAX,double v5=DBL_MAX,double v6=DBL_MAX)
{
   double result=v1;
   if(v2<result)  result=v2;
   if(v3<result)  result=v3;
   if(v4<result)  result=v4;
   if(v5<result)  result=v5;
   if(v6<result)  result=v6;
   return result;
}
static double MyMath::cap(double in,double _max,double _min)
{
   if(_max<_min)
   {
      Tools::error("max<min");
      return 0;
   }
   double result=in;
   if(result>_max)
      result=_max;
   if(result<_min)
      result=_min;
   return result;
}

static int MyMath::sign(double in)
{
   if(in<0)
      return -1;
   else if(in>0)
      return 1;
   else return 0;
}
static double MyMath::abs(double in)
{
   if(in<0)
      return -in;
   else 
      return in;
}
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
