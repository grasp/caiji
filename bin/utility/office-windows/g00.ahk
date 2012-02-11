#SingleInstance force

SetTitleMatchMode 2
IfWinNotExist, mongodb.bat
{
 run C:\WINDOWS\system32\cmd.exe /k mongodb.bat
}

IfWinNotExist, redis.bat
{
 run C:\WINDOWS\system32\cmd.exe /k redis.bat
}

IfWinNotExist, Notepad++
{
run notepad++
}

IfWinNotExist, NetBeans
{
run C:\Program Files\NetBeans 7.0.1\bin\netbeans.exe
}

IfWinNotExist, ahk_class Chrome_WidgetWin_0
{
run D:\Profiles\w22812\Local Settings\Application Data\Google\Chrome\Application\chrome.exe
}

IfWinNotExist, railscaiji.bat
{
 run C:\WINDOWS\system32\cmd.exe /k railscaiji.bat
}

IfWinNotExist, railsg00.bat
{
 run C:\WINDOWS\system32\cmd.exe /k railsg00.bat
}

exit


