//+------------------------------------------------------------------+
//|                                                        tools.mqh |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property strict

#include <MyHeaders\Screen.mqh>

class Tools
{
//   static Screen *screen;
   int i;
  public: 
   static void error(string _str);
   Tools();
};
void Tools::error(string _str)
{
   Print("Error Reported:"+_str);
//   Tools::screen.add_L1_comment(_str);
}
Tools::Tools()
{
//  Tools::screen=&_screen;
  //Tools::error("");
}
/*
static void tools::same_line(int file_handle)
{
   FileSeek(file_handle,-2,SEEK_CUR);
}
*/
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
