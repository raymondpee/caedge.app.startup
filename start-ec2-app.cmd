@echo off
cd /d "%~dp0"

REM 设置 PEM 文件名
set PEM_FILE=CAEDGE_DEVELOPER.pem

REM 去除权限继承
icacls "%PEM_FILE%" /inheritance:r

REM 移除所有用户访问
icacls "%PEM_FILE%" /remove:g "Users"
icacls "%PEM_FILE%" /remove:g "Authenticated Users"

REM 只赋予当前用户读取权限
icacls "%PEM_FILE%" /grant:r "%USERNAME%:R"

REM 启动 PowerShell 脚本
powershell.exe -NoExit -ExecutionPolicy Bypass -File .\start-ec2-app.ps1

pause
