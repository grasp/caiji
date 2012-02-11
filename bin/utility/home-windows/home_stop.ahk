#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode 2


ifWinExist,mongodb.bat
{
winclose
}

ifWinExist,redis.bat
{
winclose
}
ifWinExist,rails_g00.bat
{
winclose
}
ifWinExist,rails_caiji.bat
{
winclose
}

ifWinExist,ahk_class Chrome_WidgetWin_0
{
winclose
}

ifWinExist,NetBeans
{
winclose
}


