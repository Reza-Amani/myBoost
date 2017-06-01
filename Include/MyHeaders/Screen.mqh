//+------------------------------------------------------------------+
//|                                                       Screen.mqh |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property strict
class Screen
{
  public:
   void clear_L1_comment();
   void add_L1_comment(string str); //add to residual comment
   void clear_L2_comment();
   void add_L2_comment(string str); //add to semi-volatile comment
   void clear_L3_comment();
   void add_L3_comment(string str); //add to volatile comment
  private:
   string L1_str,L2_str,L3_str;
   void show_it();
};
void Screen::clear_L1_comment(void)
{
   L1_str="";
   show_it();
}
void Screen::add_L1_comment(string str)
{
   L1_str+=str;
   show_it();
}
void Screen::clear_L2_comment(void)
{
   L2_str="";
   show_it();
}
void Screen::add_L2_comment(string str)
{
   L2_str+=str;
   show_it();
}
void Screen::clear_L3_comment(void)
{
   L3_str="";
   show_it();
}
void Screen::add_L3_comment(string str)
{
   L3_str+=str;
   show_it();
}
void Screen::show_it(void)
{
   Comment(L1_str,"\r\n",L2_str,"\r\n",L3_str,"\r\n");
}
