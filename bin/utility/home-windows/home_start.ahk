#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode 2


ifWinNotExist,mongodb.bat
{
run C:\WINDOWS\system32\cmd.exe /k mongodb.bat
}

ifWinNotExist,redis.bat
{
run C:\WINDOWS\system32\cmd.exe /k redis.bat
}
ifWinNotExist,rails_g00.bat
{
run C:\WINDOWS\system32\cmd.exe /k rails_g00.bat
}
ifWinNotExist,rails_caiji.bat
{
run C:\WINDOWS\system32\cmd.exe /k rails_caiji.bat
}

ifWinNotExist,ahk_class Chrome_WidgetWin_0
{
run C:\Documents and Settings\Administrator\Local Settings\Application Data\Google\Chrome\Application\chrome.exe
}

ifWinNotExist,NetBeans
{
run C:\Program Files\NetBeans 7.0.1\bin\netbeans.exe
}


