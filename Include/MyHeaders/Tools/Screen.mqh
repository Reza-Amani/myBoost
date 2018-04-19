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
   void add_L1_comment(string str); //prog
   void clear_L2_comment();
   void add_L2_comment(string str); //trade
   void clear_L3_comment();
   void add_L3_comment(string str); //algo
   void clear_L4_comment();
   void add_L4_comment(string str); //add to volatile comment
   void clear_L5_comment();
   void add_L5_comment(string str); //general debug
   void clear_L6_comment();
   void add_L6_comment(string str); //general debug
   void clear_L7_comment();
   void add_L7_comment(string str); //general debug
   void clear_L8_comment();
   void add_L8_comment(string str); //general debug
  private:
   string L1_str,L2_str,L3_str,L4_str,L5_str,L6_str,L7_str,L8_str;
   void show_it();
};
void Screen::clear_L1_comment(void)
{
   L1_str="Prog: ";
   show_it();
}
void Screen::add_L1_comment(string str)
{
   L1_str+=str;
   show_it();
}
void Screen::clear_L2_comment(void)
{
   L2_str="Trade: ";
   show_it();
}
void Screen::add_L2_comment(string str)
{
   L2_str+=str;
   show_it();
}
void Screen::clear_L3_comment(void)
{
   L3_str="Algo: ";
   show_it();
}
void Screen::add_L3_comment(string str)
{
   L3_str+=str;
   show_it();
}
void Screen::clear_L4_comment(void)
{
   L4_str="";
   show_it();
}
void Screen::add_L4_comment(string str)
{
   L4_str+=str;
   show_it();
}
void Screen::clear_L5_comment(void)
{
   L5_str="Dbg: ";
   show_it();
}
void Screen::add_L5_comment(string str)
{
   L5_str+=str;
   show_it();
}
void Screen::clear_L6_comment(void)
{
   L6_str="Dbg: ";
   show_it();
}
void Screen::add_L6_comment(string str)
{
   L6_str+=str;
   show_it();
}
void Screen::clear_L7_comment(void)
{
   L7_str="Dbg: ";
   show_it();
}
void Screen::add_L7_comment(string str)
{
   L7_str+=str;
   show_it();
}
void Screen::clear_L8_comment(void)
{
   L8_str="Dbg: ";
   show_it();
}
void Screen::add_L8_comment(string str)
{
   L8_str+=str;
   show_it();
}
void Screen::show_it(void)
{
   Comment(L1_str,"\r\n",L2_str,"\r\n",L3_str,"\r\n",L4_str,"\r\n",L5_str,"\r\n",L6_str,"\r\n",L7_str,"\r\n",L8_str,"\r\n");
}
