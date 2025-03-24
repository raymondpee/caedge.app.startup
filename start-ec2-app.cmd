@echo off
cd d %~dp0
powershell.exe -NoExit -ExecutionPolicy Bypass -File .\start-ec2-app.ps1
pause
