@echo off
title PVP Shot Test Server (UTF-8 console mode)
cd /d "%~dp0"

rem 备选启动脚本：适用于终端已经设成 UTF-8 的场合（例如 Windows Terminal
rem 里手动执行过 chcp 65001，或系统开启了 Beta: 使用 Unicode UTF-8 支持）。
rem 关键点：控制台与 Java 的 stdout 必须用同一种编码，
rem 所以这里 chcp 65001 的同时，也把 stdout/stderr 显式指定为 UTF-8。

chcp 65001 >nul
set "JAVA_HOME=C:\Users\Lenovo\AppData\Local\Programs\Microsoft\jdk-25.0.2.10-hotspot"
if not exist "%JAVA_HOME%\bin\java.exe" (
    echo [ERROR] JDK 25 not found: %JAVA_HOME%
    pause
    exit /b 1
)

echo Starting PVP Shot test server (UTF-8 mode) ... port 25566
"%JAVA_HOME%\bin\java.exe" -Xms1G -Xmx3G ^
  -XX:+UseG1GC -XX:MaxGCPauseMillis=200 ^
  -Dfile.encoding=UTF-8 ^
  -Dstdout.encoding=UTF-8 ^
  -Dstderr.encoding=UTF-8 ^
  -Djava.awt.headless=true ^
  -jar fabric-server-launch.jar nogui

echo.
echo Server stopped.
pause
