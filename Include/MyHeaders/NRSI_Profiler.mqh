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
class results
{
   int no_of_occurance;
   int no_of_high;
   float filtered_output;
   float filtered_next_high;
   float filtered_next_low;   
 public:
   results():no_of_occurance(2),no_of_high(1),filtered_output(0.5),filtered_next_high((float)0.002),filtered_next_low((float)-0.002)
   {
   }

};
class NRSI_Profiler
{
   double close,nrsi0,nrsi1;
   IND_NRSI_STATES state;
   NRSI_SECTION section;

 public:
   void UpdateData(double close,double nrsi0,double nrsi1);
  
   void UpdateResult(double close, double next_close, double next_high, double next_low);
};
