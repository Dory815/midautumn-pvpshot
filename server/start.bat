@echo off
rem ============ 编码说明（改之前请先读完） ============
rem 实测结论：Minecraft 的日志走 log4j，**固定输出 UTF-8**
rem （与 -Dstdout.encoding 无关）。所以必须把控制台也切成 UTF-8
rem （chcp 65001），两边才能对上；之前试过的
rem "不动代码页、让 Java 按 GBK 输出" 是错的。
rem 本文件的提示文字全部用英文：.bat 本身按系统代码页解析，
rem 中文写在这里容易变成新的乱码源（中文说明见 README.md）。
rem ==================================================
chcp 65001 >nul
title PVP Shot Test Server (port 25566)
cd /d "%~dp0"

set "JAVA_HOME=C:\Users\Lenovo\AppData\Local\Programs\Microsoft\jdk-25.0.2.10-hotspot"
if not exist "%JAVA_HOME%\bin\java.exe" (
    echo [ERROR] JDK 25 not found: %JAVA_HOME%
    pause
    exit /b 1
)

echo Starting PVP Shot test server ... port 25566, online-mode=true
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
