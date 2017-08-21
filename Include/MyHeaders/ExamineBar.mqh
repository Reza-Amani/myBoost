//+------------------------------------------------------------------+
//|                                                   ExamineBar.mqh |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property strict

#include <MyHeaders\Pattern.mqh>

#define MAX_AC1   2

enum ConcludeCriterion
{
   USE_HC1,
   USE_aveC1,
   USE_HC1aveC1,
   USE_HH1
};
class ExamineBar
{
  public:
   ExamineBar(int _barno, Pattern* _pattern);
   int barno;
   Pattern* pattern;

   int number_of_hits;
   int potential;
   double sum_ac1;
   double higher_c1,higher_h1; //number of bars with a higher high or close
   int direction;
   double ave_aH1,ave_aL1;

   void log_to_file_common(int file_handle);
   void log_to_file_tester(int file_handle);
   bool check_another_bar(Pattern &_check_pattern, int _correlation_thresh, int _max_hit);
   bool conclude(ConcludeCriterion _criterion, int _min_hits, int _thresh_hC, double _thresh_aC);

  private:
   double sum_aH1,sum_aL1;
   int asses_use_hc1(int _thresh_hC);
   int asses_use_hh1(int _thresh_hC);
   int asses_use_ac1(double _thresh_aC);
   int asses_use_hc1ac1(int _thresh_hC, double _thresh_aC);
};
ExamineBar::ExamineBar(int _barno, Pattern* _pattern)
{
   barno=_barno; pattern=_pattern;
   number_of_hits=0;
   sum_ac1=0;
   higher_c1=0; higher_h1=0;
   potential=0;
   direction=0;
   sum_aH1=0; sum_aL1=0;
   ave_aH1=0; ave_aL1=0;
}

void ExamineBar::log_to_file_common(int file_handle)
{
   cont;
   FileWrite(file_handle,"","Bar",barno);
   cont;
   FileWrite(file_handle,"","hits",number_of_hits);
//   cont;
//   if(number_of_hits!=0)
//      FileWrite(file_handle,"","aveaC1",sum_ac1/number_of_hits);
   cont;
   if(number_of_hits!=0)
      FileWrite(file_handle,"","higherH1",higher_h1,higher_h1/number_of_hits);
   cont;
   if(number_of_hits!=0)
      FileWrite(file_handle,"","SR&direction",potential,direction);
   cont;
   if(number_of_hits!=0)
      FileWrite(file_handle,"","ave_aH1_aL1",ave_aH1,ave_aL1);
   cont;
   pattern.log_to_file(file_handle);

}

void ExamineBar::log_to_file_tester(int file_handle)
{
   if(number_of_hits!=0)
      FileWrite(file_handle,"","Normalised Result-dH1-1/0",direction*(pattern.fh1-pattern.high[0]),(direction*(pattern.fh1-pattern.high[0])>0)?1:0);
/*   if(number_of_hits!=0)
      FileWrite(file_handle,"","dC1-ac1-nextdir",pattern.fc1-pattern.close[0],pattern.ac1,(pattern.ac1>0)?1:-1);
   cont;
   if(number_of_hits!=0)
      FileWrite(file_handle,"","Normalised Result-dH1-aC1-dir",direction*(pattern.fc1-pattern.close[0]),direction*pattern.ac1,direction*((pattern.ac1>0)?1:-1));
*/
}

bool ExamineBar::check_another_bar(Pattern &_check_pattern, int _correlation_thresh, int _max_hit)
{  //returns true, if the number of matches is above 100
   int correlation;
   correlation = pattern && _check_pattern;
   if( correlation >= _correlation_thresh)
   {  //found a match!
      number_of_hits++;
      sum_ac1+=MyMath::cap(_check_pattern.ac1,MAX_AC1,-MAX_AC1);
      sum_aH1+=_check_pattern.aH1;
      sum_aL1+=_check_pattern.aL1;
      if(_check_pattern.fc1>_check_pattern.close[0])
         higher_c1++;
      if(_check_pattern.fh1>_check_pattern.high[0])
         higher_h1++;

   }
   return (number_of_hits>=_max_hit);
}

bool ExamineBar::conclude(ConcludeCriterion _criterion, int _min_hits, int _thresh_hC, double _thresh_aC)
{ //return false if not suitable bar. direction shows the suggestion
   if(number_of_hits<_min_hits)
      return false;
   ave_aH1=sum_aH1/number_of_hits;
   ave_aL1=sum_aL1/number_of_hits;
   switch(_criterion)
   {
      case USE_HC1:
         potential = asses_use_hc1(_thresh_hC);
         direction=MyMath::sign(potential);
         if(direction!=0)
            return true;
         break;
      case USE_aveC1:
         potential = asses_use_ac1(_thresh_aC);
         direction=MyMath::sign(potential);
         if(direction!=0)
            return true;
         break;
      case USE_HC1aveC1:
         potential = asses_use_hc1ac1(_thresh_hC,_thresh_aC);
         direction=MyMath::sign(potential);
         if(direction!=0)
            return true;
         break;
      case USE_HH1:
         potential = asses_use_hh1(_thresh_hC);
         direction=MyMath::sign(potential);
         if(direction!=0)
            return true;
         break;

   }
   return false;
}

int ExamineBar::asses_use_hc1(int _thresh_hC)
{  //_thresh_hC..100 for buy potential, -_thresh_hC..-100 for sell potential
   int result = (int)(200*higher_c1/number_of_hits-100);
   if(MathAbs(result)<_thresh_hC)
      result=0;
   result=(int)MyMath::cap(result,100,-100);
   return result;
}

int ExamineBar::asses_use_hh1(int _thresh_hC)
{  //_thresh_hC..100 for buy potential, -_thresh_hC..-100 for sell potential
   int result = (int)(200*higher_h1/number_of_hits-100);
   if(MathAbs(result)<_thresh_hC)
      result=0;
   result=(int)MyMath::cap(result,100,-100);
   return result;
}

int ExamineBar::asses_use_ac1(double _thresh_aC)
{  //_thresh_aC..100 for buy potential, _thresh_aC..-100 for sell potential
   int result = (int)(100*sum_ac1/number_of_hits);
   if(MathAbs(result)<_thresh_aC)
      result=0;
   result=(int)MyMath::cap(result,100,-100);
   return result;
}

int ExamineBar::asses_use_hc1ac1(int _thresh_hC, double _thresh_aC)
{
   int result_ac1 = (int)(100*sum_ac1/number_of_hits);
   if(MathAbs(result_ac1)<_thresh_aC)
      result_ac1=0;
   result_ac1=(int)MyMath::cap(result_ac1,100,-100);
   int result_hc1 = (int)(200*higher_c1/number_of_hits-100);
   if(MathAbs(result_hc1)<_thresh_hC)
      result_hc1=0;
   result_hc1=(int)MyMath::cap(result_hc1,100,-100);
   
   int result=0;
   if(result_ac1*result_hc1>0)
      result= (result_hc1+result_ac1)/2;
   
   return result;
}
