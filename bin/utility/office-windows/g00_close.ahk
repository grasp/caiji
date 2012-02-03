#SingleInstance force

SetTitleMatchMode 2
IfWinExist, mongodb.bat
{
 winclose
}

IfWinExist, redis.bat
{
 winclose
}

IfWinExist, Notepad++
{
 winclose
}

IfWinExist, NetBeans
{
 winclose
}

IfWinExist, ahk_class Chrome_WidgetWin_0
{
 winclose
}

IfWinExist, railscaiji.bat
{
  winclose
}

IfWinExist, railsg00.bat
{
  winclose
}
exit
