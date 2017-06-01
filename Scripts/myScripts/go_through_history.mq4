//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs
//--- input parameters
input int      pattern_len=5;
input int      back_search_len=20000;
input int      history=40000;
input double   correlation_thresh=93;
//----macros
#define _min_hit 5
#define _MAX_ALPHA 2.5  //here the base diff is the average of absolute value of diffs (close0-close1)
//----globals
double alpha_C1[100],alpha_H1[100],alpha_L1[100],alpha_C2[100],alpha_H2[100],alpha_L2[100];
int sister_bar_no[100];
string logstr="";
int no_of_hits_p0=0;
int no_of_hits_pthresh=0;
int no_of_output_lines=0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
class MyDateClass
  {
public:
   int               m_year;          // Year
   int               m_month;         // Month
};
void OnStart()
  {
//---
   add_log("script started");
   int outfilehandle=FileOpen("./trydata/go_through_history_"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');
   if(outfilehandle<0)
     {
      Comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return;
     }
   add_log("file ok\r\n");

   int history_size=min(Bars,history);
   int number_of_hits,no_of_b1_higher,no_of_b2_higher,par1,par2,par3;
   double close1_ave_higher,close2_ave_higher,H2_ave_higher_close0;
//   double close1_ave_higher,close2_ave_higher,H2_ave_higher_close0;
   double corrH,corrL,corrS;
   double aH,aL;
   for(int _ref=10;_ref<history_size-back_search_len;_ref++)
     {
      number_of_hits = 0;
      no_of_b1_higher=0;
      no_of_b2_higher=0;
      par1=0;par2=0;par3=0;close1_ave_higher=0;close2_ave_higher=0;H2_ave_higher_close0=0;
      for(int j=10;j<back_search_len-pattern_len;j++)
        {
         corrH = correlation_high(_ref,_ref+j,pattern_len);
         corrL = correlation_low(_ref,_ref+j,pattern_len);
         corrS = correlation_bar_size(_ref,_ref+j,pattern_len);
         if( (corrH>correlation_thresh) &&
             (corrL>correlation_thresh) &&
             (corrS>correlation_thresh) )
           {
            //saving alpha's for next 2 bars
            aH=alpha(High[_ref+j], Low[_ref+j], High[_ref+j-1]);
            aL=alpha(High[_ref+j], Low[_ref+j], Low[_ref+j-1]);
            aH=min(aH,_MAX_ALPHA);
            aL=max(aL,-_MAX_ALPHA);
            alpha_H1[number_of_hits] = aH;
            alpha_L1[number_of_hits] = aL;
            aH=alpha(High[_ref+j], Low[_ref+j], High[_ref+j-2]);
            aL=alpha(High[_ref+j], Low[_ref+j], Low[_ref+j-2]);
            aH=min(aH,_MAX_ALPHA);
            aL=max(aL,-_MAX_ALPHA);
            alpha_H2[number_of_hits] = aH;
            alpha_L2[number_of_hits] = aL;
            sister_bar_no[number_of_hits]=_ref+j;

            if((High[_ref+j-1]+Low[_ref+j-1])/2>(High[_ref+j]+Low[_ref+j])/2)
               no_of_b1_higher++;
            if((High[_ref+j-2]+Low[_ref+j-2])/2>(High[_ref+j]+Low[_ref+j])/2)
               no_of_b2_higher++;

            if(High[_ref+j-2]>High[_ref+j])
               par1++;
            if(High[_ref+j-2]>price_fromalpha(High[_ref+j],Low[_ref+j],0.5))
               par2++;
            if(High[_ref+j-2]>price_fromalpha(High[_ref+j],Low[_ref+j],0.5+0.5))
               par3++;

            //            FileWrite(outfilehandle,High[_ref],High[_ref+j], Low[_ref+j], High[_ref+j-1],aH, Low[_ref+j-1],aL);
            number_of_hits++;
            if(number_of_hits>=100)
               break;
           }
        }  //end of search for sisters

      if(number_of_hits>_min_hit)
        {
         double ave_alphaH = array_ave(alpha_H1,number_of_hits);
         double ave_alphaL = array_ave(alpha_L1,number_of_hits);
         //double DiffPips = MathAbs(NormalizeDouble(var1-cprice,Digits)/Point);         
         int stragegy_halfhigher1_profit_sum=0, stragegy_halfhigher1_noof_profits=0, stragegy_halfhigher1_noof_losses=0;
         int stragegy_halfhigher2_profit_sum=0, stragegy_halfhigher2_noof_profits=0, stragegy_halfhigher2_noof_losses=0;
         int stragegy_lowclose_profit_sum=0, stragegy_lowclose_noof_profits=0, stragegy_lowclose_noof_losses=0;
         int stragegy_openHigh_profit_sum=0, stragegy_openHigh_noof_profits=0, stragegy_openHigh_noof_losses=0;
         int stragegy_openHighifl_profit_sum=0,stragegy_openHighifl_noof_profits=0,stragegy_openHighifl_noof_losses=0;
         int stragegy_openLow_profit_sum=0,stragegy_openLow_noof_profits=0,stragegy_openLow_noof_losses=0;
         for(int i=0;i<number_of_hits;i++)
           {
            int trade_pips;

            trade_pips=strategy_halfhigher1_exe(sister_bar_no[i],ave_alphaH,ave_alphaL);
            stragegy_halfhigher1_profit_sum+=trade_pips;
            if(trade_pips>0)
               stragegy_halfhigher1_noof_profits++;
            if(trade_pips<0)
               stragegy_halfhigher1_noof_losses++;

            trade_pips=strategy_halfhigher2_exe(sister_bar_no[i],ave_alphaH,ave_alphaL);
            stragegy_halfhigher2_profit_sum+=trade_pips;
            if(trade_pips>0)
               stragegy_halfhigher2_noof_profits++;
            if(trade_pips<0)
               stragegy_halfhigher2_noof_losses++;

            trade_pips=strategy_lowclose_exe(sister_bar_no[i],ave_alphaH,ave_alphaL);
            stragegy_lowclose_profit_sum+=trade_pips;
            if(trade_pips>0)
               stragegy_lowclose_noof_profits++;
            if(trade_pips<0)
               stragegy_lowclose_noof_losses++;

            trade_pips=strategy_openHigh_exe(sister_bar_no[i],ave_alphaH,ave_alphaL);
            stragegy_openHigh_profit_sum+=trade_pips;
            if(trade_pips>0)
               stragegy_openHigh_noof_profits++;
            if(trade_pips<0)
               stragegy_openHigh_noof_losses++;

            trade_pips=strategy_openHighifl_exe(sister_bar_no[i],ave_alphaH,ave_alphaL);
            stragegy_openHighifl_profit_sum+=trade_pips;
            if(trade_pips>0)
               stragegy_openHighifl_noof_profits++;
            if(trade_pips<0)
               stragegy_openHighifl_noof_losses++;

            trade_pips=strategy_openLow_exe(sister_bar_no[i],ave_alphaH,ave_alphaL);
            stragegy_openLow_profit_sum+=trade_pips;
            if(trade_pips>0)
               stragegy_openLow_noof_profits++;
            if(trade_pips<0)
               stragegy_openLow_noof_losses++;

           }

         //         if( ((stragegy_openclose_profit_sum>0)&&(stragegy_openclose_noof_profits > stragegy_openclose_noof_losses))
         //            || ((stragegy_openclose_profit_sum<0)&&(stragegy_openclose_noof_profits < stragegy_openclose_noof_losses)) )
         if(number_of_hits>20)
//            if( (stragegy_halfhigher1_noof_profits>2 *stragegy_halfhigher1_noof_losses)
//            ||(stragegy_halfhigher1_noof_profits*2 <stragegy_halfhigher1_noof_losses) )
              {
               FileWrite(outfilehandle,_ref,High[_ref],number_of_hits,
                         "alpha",ave_alphaH,ave_alphaL,
                         "st_halfhigher1",stragegy_halfhigher1_profit_sum,stragegy_halfhigher1_noof_profits,stragegy_halfhigher1_noof_losses,strategy_halfhigher1_exe(_ref,ave_alphaH,ave_alphaL),
//                         "st_halfhigher2",stragegy_halfhigher2_profit_sum,stragegy_halfhigher2_noof_profits,stragegy_halfhigher2_noof_losses,strategy_halfhigher2_exe(_ref,ave_alphaH,ave_alphaL),
                         "b1higher",(int)100*no_of_b1_higher/number_of_hits,
                         "h2higher",(int)100*par1/number_of_hits,
                         "h2higherp",(int)100*par2/number_of_hits,
                         "h2highera1",(int)100*par3/number_of_hits,
                         "11111",High[_ref+0],High[_ref+1],High[_ref+2],High[_ref+3],High[_ref+4],Low[_ref+0],Low[_ref+1],Low[_ref+2],Low[_ref+3],Low[_ref+4],
                         "");
               no_of_output_lines++;          
              }  //end of logging/trading selected patterns
        }  //end of sisters process
      if(number_of_hits>0)
         no_of_hits_p0++;
      if(number_of_hits>_min_hit)
         no_of_hits_pthresh++;
      show_log_plus("Bar: ",_ref," /",history_size-back_search_len,"\r\nno_of_hits_p0 ",no_of_hits_p0,"\r\nno_of_hits_p10 ",no_of_hits_pthresh,"\r\nno_of_output_lines ",no_of_output_lines);
     }
   FileClose(outfilehandle);
   Print("Done");

  }
//////////////////////////////////////////////////////////////////////////////////////////////strategies
int strategy_halfhigher1_exe(int bar_no,double _ave_alphaH,double _ave_alphaL)
  {  //simulates the strategy on bar_no-1 and returns the revenue in pips
   if(Low[bar_no-1]+High[bar_no-1]>Low[bar_no]+High[bar_no]) //half price grows
      return 1;
   else
      return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int strategy_halfhigher2_exe(int bar_no,double _ave_alphaH,double _ave_alphaL)
  {  //simulates the strategy on bar_no-1 and returns the revenue in pips
   if(Low[bar_no-2]+High[bar_no-2]>Low[bar_no]+High[bar_no]) //half price in second bar grows 
      return 1;
   else
      return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int strategy_lowclose_exe(int bar_no,double _ave_alphaH,double _ave_alphaL)
  {  //simulates the strategy on bar_no-1 and returns the revenue in pips
   double buy_limit_price=price_fromalpha(High[bar_no],Low[bar_no],_ave_alphaL);
   if(Low[bar_no-1]>buy_limit_price) //doesn't reach the buy limit
      return 0;
   double result=Close[bar_no-1]-buy_limit_price;
   return (int)(NormalizeDouble(result,Digits)/Point);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int strategy_openHigh_exe(int bar_no,double _ave_alphaH,double _ave_alphaL)
  {  //simulates the strategy on bar_no-1 and returns the revenue in pips
   double buy_take_profit=price_fromalpha(High[bar_no],Low[bar_no],_ave_alphaH);
   double ask=Open[bar_no-1];
   double result;
   if(buy_take_profit<=ask) //no trade, small tp
      return 0;
   if(High[bar_no-1]<buy_take_profit) //doesn't reach to tp
      result=Close[bar_no-1]-ask;
   else//tp
   result=buy_take_profit-ask;
   return (int)(NormalizeDouble(result,Digits)/Point);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int strategy_openHighifl_exe(int bar_no,double _ave_alphaH,double _ave_alphaL)
  {  //simulates the strategy on bar_no-1 and returns the revenue in pips
   double buy_take_profit=price_fromalpha(High[bar_no],Low[bar_no],_ave_alphaH);
   double ask=Open[bar_no-1];
   double result;
   if(buy_take_profit<=ask) //no trade, small tp
      return 0;
   if(ask>price_fromalpha(High[bar_no],Low[bar_no],(_ave_alphaH+_ave_alphaL)/2))
      return 0;
   if(High[bar_no-1]<buy_take_profit) //doesn't reach to tp
      result=Close[bar_no-1]-ask;
   else//tp
   result=buy_take_profit-ask;
   return (int)(NormalizeDouble(result,Digits)/Point);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int strategy_openLow_exe(int bar_no,double _ave_alphaH,double _ave_alphaL)
  {  //simulates the strategy on bar_no-1 and returns the revenue in pips
   double sell_take_profit=price_fromalpha(High[bar_no],Low[bar_no],_ave_alphaL);
   double bid=Open[bar_no-1];
   double result;
   if(sell_take_profit>=bid) //no trade, small tp
      return 0;
   if(Low[bar_no-1]>sell_take_profit) //doesn't reach to tp
      result=bid-Close[bar_no-1];
   else//tp
   result=bid-sell_take_profit;
   return (int)(NormalizeDouble(result,Digits)/Point);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double array_ave(double &array[],int size)
  {
   double result=0;
   if(size==0)
      return 0;
   for(int i=0; i<size; i++)
      result+=array[i];
   return result/size;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double price_fromalpha(double refH,double refL,double alpha)
  {
   return (refL+refH)/2 + alpha * (refH-refL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double alpha(double refH,double refL,double in)
  {
   double result;
   if(refH==refL)
     {
      if(in==refL)
         return 0;
      if(in>refL)
         return _MAX_ALPHA;
      else
         return -_MAX_ALPHA;
     }
   else
     {
      result=(in-(refL+refH)/2)/(refH-refL);
      if(result>_MAX_ALPHA)
         result=_MAX_ALPHA;
      if(result<-_MAX_ALPHA)
         result=-_MAX_ALPHA;
      return result;
     }

  }
/////////////////////////////////////////////////////////////////////////////
void add_log(string str)
  {
   logstr+=str;
   Comment(logstr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void show_log_plus(string str)
  {
   Comment(logstr,str);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void show_log_plus(int i)
  {
   Comment(logstr,i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void show_log_plus(string s1,int i1,string s2,int i2,string s3,int i3,string s4,int i4,string s5,int i5)
  {
   Comment(logstr,s1,i1,s2,i2,s3,i3,s4,i4,s5,i5);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void reset_log()
  {
   logstr="";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double correlation_bar_size(int pattern1,int pattern2,int _len)
  {  //pattern1&2 are the end indexes of 2 arrays
//sigma(x-avgx)(y-avgy)/sqrt(sigma(x-avgx)2*sigma(y-avgy)2)
   double x,y;
   double avg1=0,avg2=0;
   int i;
   for(i=0; i<_len; i++)
     {
      x = High[i+pattern1]-Low[i+pattern1];
      y = High[i+pattern2]-Low[i+pattern2];
      avg1 += x;
      avg2 += y;
     }
   avg1 /= _len;
   avg2 /= _len;

   double x_xby_yb=0,x_xb2=0,y_yb2=0;
   for(i=0; i<_len; i++)
     {
      x = High[i+pattern1]-Low[i+pattern1];
      y = High[i+pattern2]-Low[i+pattern2];
      x_xby_yb+=(x-avg1)*(y-avg2);
      x_xb2 += (x-avg1)*(x-avg1);
      y_yb2 += (y-avg2)*(y-avg2);
     }

   if(x_xb2*y_yb2==0)
      return 0;

   return 100*x_xby_yb/MathSqrt(x_xb2 * y_yb2);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double correlation_high(int pattern1,int pattern2,int _len)
  {  //pattern1&2 are the end indexes of 2 arrays
//sigma(x-avgx)(y-avgy)/sqrt(sigma(x-avgx)2*sigma(y-avgy)2)
   double x,y;
   double avg1=0,avg2=0;
   int i;
   for(i=0; i<_len; i++)
     {
      x = High[i+pattern1];
      y = High[i+pattern2];
      avg1 += High[i+pattern1];
      avg2 += High[i+pattern2];
     }
   avg1 /= _len;
   avg2 /= _len;

   double x_xby_yb=0,x_xb2=0,y_yb2=0;
   for(i=0; i<_len; i++)
     {
      x = High[i+pattern1];
      y = High[i+pattern2];
      x_xby_yb+=(x-avg1)*(y-avg2);
      x_xb2 += (x-avg1)*(x-avg1);
      y_yb2 += (y-avg2)*(y-avg2);
     }

   if(x_xb2*y_yb2==0)
      return 0;

   return 100*x_xby_yb/MathSqrt(x_xb2 * y_yb2);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double correlation_low(int pattern1,int pattern2,int _len)
  {  //pattern1&2 are the end indexes of 2 arrays
//sigma(x-avgx)(y-avgy)/sqrt(sigma(x-avgx)2*sigma(y-avgy)2)
   double x,y;
   double avg1=0,avg2=0;
   int i;
   for(i=0; i<_len; i++)
     {
      x = Low[i+pattern1];
      y = Low[i+pattern2];
      avg1 += Low[i+pattern1];
      avg2 += Low[i+pattern2];
     }
   avg1 /= _len;
   avg2 /= _len;

   double x_xby_yb=0,x_xb2=0,y_yb2=0;
   for(i=0; i<_len; i++)
     {
      x = Low[i+pattern1];
      y = Low[i+pattern2];
      x_xby_yb+=(x-avg1)*(y-avg2);
      x_xb2 += (x-avg1)*(x-avg1);
      y_yb2 += (y-avg2)*(y-avg2);
     }

   if(x_xb2*y_yb2==0)
      return 0;

   return 100*x_xby_yb/MathSqrt(x_xb2 * y_yb2);

  }
//general funcs
//+------------------------------------------------------------------+
double max(double v1,double v2=-DBL_MAX,double v3=-DBL_MAX,double v4=-DBL_MAX,double v5=-DBL_MAX,double v6=-DBL_MAX)
  {
   double result=v1;
   if(v2>result)  result=v2;
   if(v3>result)  result=v3;
   if(v4>result)  result=v4;
   if(v5>result)  result=v5;
   if(v6>result)  result=v6;
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double min(double v1,double v2=DBL_MAX,double v3=DBL_MAX,double v4=DBL_MAX,double v5=DBL_MAX,double v6=DBL_MAX)
  {
   double result=v1;
   if(v2<result)  result=v2;
   if(v3<result)  result=v3;
   if(v4<result)  result=v4;
   if(v5<result)  result=v5;
   if(v6<result)  result=v6;
   return result;
  }

/*   if(iClose("EURUSD", PERIOD_M5, 0) > iHigh("EURUSD", PERIOD_M5, 1) &&
      iClose("EURCHF", PERIOD_M5, 0) > iHigh("EURCHF", PERIOD_M5, 1) &&
      iClose("EURAUD", PERIOD_M5, 0) > iHigh("EURAUD", PERIOD_M5, 1) &&
      iClose("EURJPY", PERIOD_M5, 0) > iHigh("EURJPY", PERIOD_M5, 1)   ){
      Print("EUR is strong!");
*/
//+------------------------------------------------------------------+
