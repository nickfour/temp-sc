@echo off
:loop
set /a "rand=100000 + %random% %% 900000"
echo %rand%
powershell -Command "$code = '%rand%'; Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait($code)"
goto loop
