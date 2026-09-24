@echo off
chcp 65001 >nul
title PVP Shot Test Server (port 25566)
cd /d "%~dp0"

set "JAVA_HOME=C:\Users\Lenovo\AppData\Local\Programs\Microsoft\jdk-25.0.2.10-hotspot"
if not exist "%JAVA_HOME%\bin\java.exe" (
    echo [错误] 找不到 JDK 25：%JAVA_HOME%
    pause
    exit /b 1
)

echo 正在启动 PVP Shot 测试服（端口 25566，正版验证开启）...
"%JAVA_HOME%\bin\java.exe" -Xms1G -Xmx3G ^
  -XX:+UseG1GC -XX:MaxGCPauseMillis=200 ^
  -Dfile.encoding=UTF-8 ^
  -jar fabric-server-launch.jar nogui

echo.
echo 服务端已退出。
pause
