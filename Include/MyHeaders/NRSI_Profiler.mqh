//+------------------------------------------------------------------+
//|                                                NRSI_Profiler.mqh |
//|                                                             Reza |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "http://www.mql4.com"
#property strict
enum NRSI_SECTION
{
   NRSI_SECTION_NONE,
   NRSI_SECTION_RISING_MINUS75,
   NRSI_SECTION_RISING_MINUS75_45,
   NRSI_SECTION_RISING_MINUS45_15,
   NRSI_SECTION_RISING_15_15,
   NRSI_SECTION_RISING_PLUS15_45,
   NRSI_SECTION_RISING_PLUS45_75,
   NRSI_SECTION_RISING_PLUS75,
   NRSI_SECTION_SIZE
};
enum IND_NRSI_STATES
{
   NRSI_RISING,
   NRSI_FALLSING
};
//+------------------------------------------------------------------+
#define RESULTS_FILTER_LEN 10
class Results
{
   int filter_len;
 public:
   int no_of_occurance;
   int no_of_high;
   double filtered_binary_output;
   double filtered_next_high;
   double filtered_next_low;   
   Results():filter_len(RESULTS_FILTER_LEN),no_of_occurance(2),no_of_high(1),filtered_binary_output(0),filtered_next_high((float)0.002),filtered_next_low((float)-0.002)
   {
   }
   void UpdateResult(bool if_close_higher, double diff_to_high, double diff_to_low)
   {
      no_of_occurance++;
      filtered_next_high = (filtered_next_high*filter_len + diff_to_high)/(filter_len+1);
      filtered_next_low = (filtered_next_low*filter_len + diff_to_low)/(filter_len+1);
      if(if_close_higher)
      {
         no_of_high++;
         filtered_binary_output = (filtered_binary_output*filter_len + 1)/(filter_len+1);
      }
      else
         filtered_binary_output = (filtered_binary_output*filter_len - 1)/(filter_len+1);
   }
};
class NRSI_Profiler
{
   Results results;
   double close,nrsi0,nrsi1;
   IND_NRSI_STATES state;
   NRSI_SECTION section;

 public:
   void UpdateData(double close,double nrsi0,double nrsi1);
  
   void UpdateResult(double this_close, double next_close, double next_high, double next_low)
   {
      results.UpdateResult( next_close>this_close, next_high-this_close, next_low-this_close);
   }
};
